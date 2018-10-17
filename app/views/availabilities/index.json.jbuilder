json.array!(@availabilities) do |availability|
  json.extract! availability, :id
  json.url availability_url(availability, format: :json)
end
