class User < ActiveRecord::Base
  has_and_belongs_to_many :calendars
  has_many :statuses
  has_many :tasks, through: :statuses
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable

  def self.from_omniauth auth
    if token = Token.where(:provider => auth['provider'], :uid => auth['uid']).first()
      token.user
    else
      self.create_with_omniauth(auth)
    end
  end

  def self.create_with_omniauth auth
    create! do |user|
      user.password = Devise.friendly_token[0,20]
      if auth['info']
        user.firstname = auth['info']['first_name'] || ""
        user.lastname = auth['info']['last_name'] || ""
        user.email = auth['info']['email'] || ""
        user.image = auth['info']['image'] || ""
      end
    end
  end
end
