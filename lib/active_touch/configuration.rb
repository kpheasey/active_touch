module ActiveTouch

  class << self
    attr_accessor :configuration
  end

  def self.configure
    self.configuration ||= Configuration.new
    yield(configuration)
  end

  class Configuration
    attr_accessor :ignored_attributes

    def initialize
      @ignored_attributes = [:updated_at]
    end
  end

end