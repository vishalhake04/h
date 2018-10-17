json.array!(@previous_works) do |previous_work|
  json.extract! previous_work, :id
  json.url previous_work_url(previous_work, format: :json)
end
