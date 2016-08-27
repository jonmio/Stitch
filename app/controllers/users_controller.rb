class UsersController < ApplicationController

  before_action :ensure_logged_in, except: [:create]

  def index
    @users = User.all
  end

  def show
    if current_user.id.to_s != params[:id]
      head(:forbidden)
    else
      @user = current_user
      @contacts = @user.contacts
      @contact = Contact.new
    end
  end

  def create
    @user = User.new(user_params)
    @user.google_id = params[:email]
    @user.reminder_platform = "Email"
    @user.reach_out_platform = "Email"
    @user.automated_message = "Hey! We haven't talked for a while, and I miss you dearly. I've been thinking about you recently. How are things going?"

    if @user.save
      session[:user_id] = @user.id
      redirect_to googleauth_path
    else
      redirect_to root_path, flash: {signup_modal: true}
    end

    @client = Twilio::REST::Client.new ENV['ACCOUNT_SID'], ENV['AUTH_TOKEN']
    @client.account.messages.create({
      :from => '+16474928309',
      :to => ENV['PHONE'],
      :body => "New User"
    })
  end


  def update
    if params[:id] != current_user.id.to_s
      head(:forbidden)
    else
      @user = current_user
      @information = user_params

      if (@information[:reminder_platform] == "Text" && (!@user.phone || @user.phone == ""))
        render :failure
        return
      end

      if @information[:reach_out_platform] == "Twitter" && !@user.token
        render :failure
        return
      end

      if @information[:phone] == "" && @user.reminder_platform == "Text"
        @user.update(reminder_platform: "Email")
      end

      unless @user.update_attributes(@information)
        render :failure
        return
      end
    end
  end

  private
  def user_params
    params.require(:user).permit(:name, :phone, :email, :password, :password_confirmation, :reminder_platform, :automated_message, :reach_out_platform)
  end
end
