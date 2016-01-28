# Status Objects connects user with a task
# and shows if it is 'open', 'done', or 'archived'
class Status < ActiveRecord::Base
  belongs_to :task
  belongs_to :user

  def self.create user, task
    create! do |status|
    status.user_id = user.id
    status.task_id = task[:id]
    status.status = 'open'
    end
  end

  def self.create_status_for_user tasks, user
    tasks.each{ |task|
      unless Status.exists? :task_id => task[:id], :user_id => user.id
        Status.create user, task
      end
    }
  end
end
