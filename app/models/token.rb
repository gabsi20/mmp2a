require 'net/http'
require 'json'

class Token < ActiveRecord::Base
  belongs_to :user

  def self.from_omniauth auth, user
    Token.where(:provider => auth['provider'], :uid => auth['uid']).first || self.create_with_omniauth(auth, user)
  end

  def self.create_with_omniauth auth, user
    create! do |token|
      token.provider = auth['provider'] || ""
      token.token = auth['credentials']['token'] || ""
      token.refresh_token = auth['credentials']['refresh_token'] || ""
      token.expires_at = Time.at(auth['credentials']['expires_at']) || ""
      token.uid = auth['uid'] || ""
      token.user = user
    end
  end

  # refresh token based on
  # https://www.twilio.com/blog/2014/09/gmail-api-oauth-rails.html

  def to_params
    {'refresh_token' => refresh_token,
    'client_id' => ENV['GOOGLE_KEY'],
    'client_secret' => ENV['GOOGLE_SECRET'],
    'grant_type' => 'refresh_token'}
  end

  def request_token_from_google
    url = URI("https://accounts.google.com/o/oauth2/token")
    Net::HTTP.post_form(url, self.to_params)
  end

  def refresh!
    response = request_token_from_google
    data = JSON.parse(response.body)
    update_attributes(
      token: data['access_token'],
      expires_at: (Time.now + data['expires_in'])
    )
    data['access_token']
  end

  def expired?
    expires_at < Time.now
  end

  def fresh_token
    if expired?
      refresh!
    else
      self.token
    end
  end
end
