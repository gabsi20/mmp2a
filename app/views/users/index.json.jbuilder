json.array!(@users) do |user|
  json.extract! user, :id, :firstname, :lastname, :email, :provider
  json.url user_url(user, format: :json)
end
