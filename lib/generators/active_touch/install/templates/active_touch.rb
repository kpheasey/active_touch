ActiveTouch.configure do |config|
  # All touches to run synchronously or asynchronously, unless specified
  # Default is false
  # config.async = false

  # Batch size of records to touch at a time
  # Default is 100
  # config.batch_size = 100

  # When :watch is not specified, ignore the following attributes.
  # Default is [:updated_at]
  # config.ignored_attributes = [:updated_at]

  # Job queue for asynchronous jobs.
  # Default is 'default'
  # config.queue = 'default'
end