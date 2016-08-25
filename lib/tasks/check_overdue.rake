desc "Refresh the newsfeed"
task :friendship_maker => [:environment] do
  User.update_newsfeed_all_users
  User.update_reminders_all_contacts
  Misc.refresh_master_token
  User.check_overdue_all_users
end
