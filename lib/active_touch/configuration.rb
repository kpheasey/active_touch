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
    attr_accessor :associated_touch_delay, :async, :batch_process, :batch_size, :ignored_attributes,
                  :queue, :touch_process

    def initialize
      @associated_touch_delay = 0
      @async = false
      @batch_process = true
      @batch_size = 100
      @ignored_attributes = [:updated_at]
      @queue = 'default'
      @touch_process = :batch_synchronous
    end
  end

end