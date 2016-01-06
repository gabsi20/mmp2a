class Status < ActiveRecord::Base
  belongs_to :task
  belongs_to :user

  def self.create user, task
    create! do |status|
    status.user_id = user.id
    status.task_id = task[:id]
    status.status = "open"
    end
  end
end
