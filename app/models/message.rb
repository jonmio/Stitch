class Message < ActiveRecord::Base
  #ActiveRecord associations
  belongs_to :contact
  belongs_to :user
end
