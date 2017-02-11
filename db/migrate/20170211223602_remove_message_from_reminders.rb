class RemoveMessageFromReminders < ActiveRecord::Migration
  def change
    remove_column :reminders, :message
  end
end
