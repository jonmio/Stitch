desc "Runs daily. Updates reminders, grabs most recent messages, and reaches out to contacts if falling out of touch"
task :makefriendship => [:environment] do
  User.update_newsfeed_all_users
  User.update_reminders_all_contacts
  Misc.refresh_master_token
  User.check_overdue_all_users
end
