class RemindersController < ApplicationController
  before_action :ensure_logged_in

  def index
    @reminders = Reminder.where(user_id:current_user.id).order(time_since_last_contact: :desc)
  end
end
