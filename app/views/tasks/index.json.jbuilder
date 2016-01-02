json.array!(@tasks) do |task|
  json.extract! task, :id, :title, :description, :autor, :participants, :due
  json.url task_url(task, format: :json)
end
