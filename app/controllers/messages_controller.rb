class MessagesController < ApplicationController
  before_action :ensure_logged_in

  def create_direct_message
    if !current_user.token
      head :bad_request
      return
    else
      DmSenderJob.perform_later(current_user, params[:user], params[:text])
      head :ok
    end
  end

  def create_tweet
    if !current_user.token
      head :bad_request
      return
    else
      TweetSenderJob.perform_later(current_user, params[:message])
      head :ok
    end
  end

  def send_mail
    MailSenderJob.perform_later(current_user,params[:receiver], params[:subj], params[:bod])
    head :ok
  end

end
