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
    attr_accessor :async, :batch_size, :ignored_attributes, :queue

    def initialize
      @async = false
      @batch_size = 100
      @ignored_attributes = [:updated_at]
      @queue = 'default'
    end
  end

end