class TweetSenderJob < ActiveJob::Base
  queue_as :default

  def perform(user,message)
    Misc.send_tweet(user, message)
  end
end
