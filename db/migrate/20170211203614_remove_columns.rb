class RemoveColumns < ActiveRecord::Migration
  def change
    remove_column :messages, :message_title
  end
end
