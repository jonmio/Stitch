class RemoveOtherIndex < ActiveRecord::Migration
  def change
    remove_index :reminders, name: "index_reminders_on_user_id"
    add_index :contacts, :user_id
    add_index :reminders, [:user_id, :contact_id]
    add_index :messages, [:user_id, :contact_id]
  end
end
