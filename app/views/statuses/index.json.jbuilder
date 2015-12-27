json.array!(@statuses) do |status|
  json.extract! status, :id, :task_id, :user_id, :status
  json.url status_url(status, format: :json)
end
