class User < ActiveRecord::Base
  has_secure_password

  validates :name, :email, presence: true
  validates :email, uniqueness: true

  has_many :contacts
  has_many :messages, through: :contacts
  has_many :reminders, through: :contacts

  def twitter_client
    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
      config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
      config.access_token        = self.token
      config.access_token_secret = self.secret
    end
    return client
  end

  #find the google-email adress on sign-in b/c user email !=  (always) their gmail
  def get_email_address
    #see if token has expired
    check_token
    #Get the email adress in json
    url = "https://www.googleapis.com/oauth2/v1/userinfo?alt=json&access_token=#{access_token}"
    user_info_json = RestClient.get(url)
    email = JSON.parse(user_info_json)['email']
    #save record in db
    self.google_id = email
    self.save
  end

  #get list of a user's google contacts
  def google_contacts
    check_token
    url = "https://www.google.com/m8/feeds/contacts/default/full?max-results=10000&access_token=#{access_token}&alt=json"
    results = JSON.parse(RestClient.get(url))
    contacts = []
    token = access_token
    results['feed']['entry'].each do |entry|
      info = {}
      info['name'] = entry['title']['$t']
      if entry['gd$email']
        info['email'] = entry['gd$email'][0]['address']
      end
      info['selected'] = false
      info['show'] = true
      contacts << info
    end
    contacts
  end

  #use refresh token to get new access token
  def refresh
    response = RestClient.post 'https://accounts.google.com/o/oauth2/token', :grant_type => 'refresh_token', :refresh_token => refresh_token, :client_id => ENV['CLIENT'], :client_secret => ENV['CLIENT_SECRET']
    refresh = JSON.parse(response.body)
    self.update(access_token:refresh['access_token'])
  end

  def save_callback_info_twitter(auth_hash)
    self.provider = auth_hash['provider']
    self.token = auth_hash['credentials']['token']
    self.secret = auth_hash['credentials']['secret']
    self.save
  end

  # check if the token is expired
  def check_token
    issued_at_time = issued_at.strftime('%s')
    issued_at_time = issued_at_time.to_i+3660
    expiry = DateTime.strptime(issued_at_time.to_s, '%s')
    if expiry < DateTime.now
      refresh
    end
  end


  def self.check_overdue_all_users
    all_users = User.all
    all_users.each do |user|
      user.check_overdue
    end
  end

  #call method to reach out to contact if you havent talked to them in 30 days or remind user if its 29
  def check_overdue
    check_token
    contacts.each do |contact|
      if contact.thirty_days?
        contact.reach_out
        puts "reaching out to #{contact.name}"
      elsif contact.twenty_nine_days?
        remind(contact)
        puts "reminding #{name} about #{contact.name}"
      end
    end
  end

  #notify user that they have neglected the contact and in one day we will reach out
  def remind(contact)
    case reminder_platform
      when "Email"
        Misc.automated_email(self, contact)
      when "Text"
        Misc.automated_text(self, contact)
    end
  end

  def self.update_newsfeed_all_users
    all.each do |user|
      user.update_newsfeed
    end
  end

  def update_newsfeed
    check_token
    contacts.each do |contact|
      contact.get_most_recent_messages
    end
  end

  def self.update_reminders_all_contacts
    all.each do |user|
      user.update_reminders
    end
  end

  def update_reminders
    contacts.each do |contact|
      contact.update_reminder
    end
  end
end
