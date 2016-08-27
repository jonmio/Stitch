class ContactsController < ApplicationController

  before_action :ensure_logged_in

  def index
    if request.xhr?
        @contacts = Contact.all.where(user_id:current_user.id)
        @contacts_render = []
        @contacts.each do |contact|
          person = contact.as_json
          person['twitter_username'] = person['twitter_username'] ? (person['twitter_username']): nil
          person['show'] = true
          @contacts_render << person
        end
        render json: @contacts_render
    else
      not_found
    end
  end

  #Show one user's info on click
  def show
    @contact = Contact.find(params[:id])
    respond_to do |format|
      format.js {}
    end
  end

  def create
    @contact = Contact.new(contact_params)
    @contact.user_id = current_user.id

    if @contact.phone.length > 0 && @contact.phone != @contact.phone.gsub(/[^\d]/, '')
      render "users/failure"
      return
    end

    if @contact.email == ""
      @contact.email = nil
    end

    if @contact.twitter_username
      if @contact.twitter_username[0] == "@"
        @contact.twitter_username.slice!(0)
      end

      unless Misc.valid_handle(@contact.twitter_username)
        render "users/failure"
        return
      end
    end

    if @contact.save
      @contact.twitter_username = @contact.twitter_username == "" ? nil : @contact.twitter_username
      respond_to do |format|
        format.js{}
      end
    else
      head :internal_server_errror
    end
  end

  def destroy
    @contact = Contact.find(params[:id])
    if @contact.user_id == current_user.id && @contact.destroy
      redirect_to user_path(current_user)
    else
      head :unauthorized
    end
  end

  def update
    @contact = Contact.find(params[:id])
    updated_info = contact_params

    if updated_info[:phone].length > 0 && updated_info[:phone] != [:phone].gsub(/[^\d]/, '')
      render "users/failure"
      return
    end

    if updated_info[:twitter_username][0] == "@"
      updated_info[:twitter_username].slice!(0)
    end

    unless Misc.valid_handle(updated_info[:twitter_username])
      render "users/failure"
      return
    end

    updated_info[:twitter_username] = updated_info[:twitter_username] =="" ? nil : updated_info[:twitter_username]

    if updated_info[:email] == ""
      updated_info[:email] = nil
    end

    if @contact.user_id == current_user.id && @contact.update_attributes(updated_info)
      respond_to do |format|
        format.js{}
      end

    else
      head :unauthorized
    end
  end

  #Path is reached when the user is clicked on a contact card on the user show page
  def edit
    @contact = Contact.find(params[:id])
    respond_to do |format|
      format.js {}  # to show the contacts info in form on all contacts page
    end
  end

  private
  def contact_params
    params.require(:contact).permit(:name, :phone, :email, :category, :twitter_username)
  end
end
