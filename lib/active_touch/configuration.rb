module ActiveTouch

  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  class Configuration
    attr_accessor :async, :ignored_attributes, :queue, :timestamp_attribute, :touch_in_transaction, :touch_updates

    def initialize
      @async = false
      @ignored_attributes = [:updated_at]
      @queue = 'default'
      @timestamp_attribute = :updated_at
      @touch_in_transaction = true
      @touch_updates = {}
    end
  end

end