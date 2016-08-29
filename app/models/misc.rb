#Class for misc. functions
class Misc < ActiveRecord::Base

  def self.refresh_master_token
    response = RestClient.post 'https://accounts.google.com/o/oauth2/token', :grant_type => 'refresh_token', :refresh_token => ENV['MASTER_REFRESH'], :client_id => ENV['CLIENT'], :client_secret => ENV['CLIENT_SECRET']
    refresh = JSON.parse(response.body)
    ENV['MASTER_TOKEN'] = refresh['access_token']
  end

  def self.automated_email(user,contact)
    subject = "You've been a pretty bad friend..."
    body = "Hey #{user.name},\n Looks like you havent talked to #{contact.name.split(" ")[0]} for almost a month. You should contact them soon or we'll be reaching out for you! \n \nThe Remind Team"

    email = Mail.new do
      from "miojonathan358@gmail.com"
      to user.email
      subject subject
      body body
    end

    message = Google::Apis::GmailV1::Message.new
    message.raw = email.to_s

    service = Google::Apis::GmailV1::GmailService.new

    service.request_options.authorization = ENV['MASTER_TOKEN']
    service.send_user_message("miojonathan358@gmail.com", message_object = message)
  end

  def self.valid_handle(twitter_handle)
    letters = twitter_handle.split("")
    letters.each do |letter|
      if letter == "@"
        return false
      end
    end

    true
  end

  def self.send_tweet(user, message)
    user.twitter_client.update(message)
  end


  #create a new client for authentication
  def self.load_google_client
    client_secrets = Google::APIClient::ClientSecrets.new(JSON.parse(ENV['GOOGLE_CLIENT_SECRETS']))
    @auth_client = client_secrets.to_authorization
    @auth_client.update!(
      :scope => 'https://www.googleapis.com/auth/userinfo.email ' +
      'https://www.googleapis.com/auth/userinfo.profile '+
      'https://www.googleapis.com/auth/gmail.readonly '+
      'https://www.googleapis.com/auth/gmail.send '+
      'https://www.googleapis.com/auth/contacts.readonly',
      :redirect_uri => 'http://stitch-app.herokuapp.com/callback'
              # :redirect_uri => 'http://localhost:3000/callback'
      )
    @auth_client
  end

  #Send email to a given email
  def self.send_mail(user, to_email, subj, bod)
    email = Mail.new do
      from user.google_id
      to to_email
      subject subj
      body bod
    end

    message = Google::Apis::GmailV1::Message.new
    message.raw = email.to_s

    service = Google::Apis::GmailV1::GmailService.new

    user.check_token

    service.request_options.authorization = user.access_token
    service.send_user_message(user.google_id, message_object = message)
  end


  def self.send_dm(user, recipient, message)
    user.twitter_client.create_direct_message(recipient, message)
  end

  def self.automated_text(user,contact)
    @client = Twilio::REST::Client.new ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN']
    number = user.phone[0] == 1 ? "+#{user.phone}" : "+1#{user.phone}"
    @client.account.messages.create({
      :from => '+16474928309',
      :to => number,
      :body => "Hey #{user.name.split(" ")[0]}, \nLooks like you havent talked to #{contact.name} for almost a month. You should contact them soon or we'll be reaching out for you! \n \nThe Stitch Team"
    })
  end
end
