class PagesController < ApplicationController
  before_action :ensure_logged_in, except: [:landing]

  def twitter_callback
    @user = current_user.save_callback_info_twitter(request.env['omniauth.auth'])
    redirect_to pull_messages_path
  end

  #ask user if we can load google contacts
  def permission
  end

  #ask user to connect with twitter
  def twitter_sync
  end

  def googleauth
    auth_uri = Misc.load_google_client.authorization_uri.to_s
    redirect_to auth_uri
  end

  #google callback
  def callback
    #if user clicks deny
    if params[:error]
      puts "error"

    #authcode in qs if user clicks allow access
    elsif params[:code]
      @auth_client = Misc.load_google_client
      @auth_client.code = params[:code]
      #exchange auth for token
      @auth_client.fetch_access_token!

      if @auth_client.refresh_token != nil
        current_user.update({access_token: @auth_client.access_token, refresh_token: @auth_client.refresh_token, issued_at: @auth_client.issued_at})
      else
        current_user.update({access_token: @auth_client.access_token, issued_at: @auth_client.issued_at})
      end
      current_user.get_email_address
    end

    redirect_to permission_path

  end

  #import contacts for new user
  def import
    if request.xhr?
      @potential_contacts = current_user.google_contacts
      render json: @potential_contacts
    end
  end

  def newsfeed
    @contacts = current_user.contacts
  end

  def landing
    @user = User.new
  end

  def pull_messages
    current_user.update_newsfeed
    current_user.update_reminders
    respond_to do |format|
      format.js{}
      format.html{redirect_to newsfeed_path}
    end
  end
end
