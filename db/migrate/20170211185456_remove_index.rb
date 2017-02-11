class RemoveIndex < ActiveRecord::Migration
  def change
    remove_index :reminders, name: "index_reminders_on_contact_id"
  end
end
