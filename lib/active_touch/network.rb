module ActiveTouch

  class << self
    attr_accessor :network
  end

  def self.network
    @network ||= Network.new
  end

  class Network

    attr_accessor :map

    def initialize
      @map = {}
    end

    # @param caller [String]
    # @param touched [String, Array(String)]
    # @param watch [Array(Symbol)]
    # @return [void]
    def add_touch(caller, touched, watch)
      map[caller] ||= []

      if touched.is_a? Array
        touched.each { |t| map[caller] << { class: t, attributes: watch } }
      else
        map[caller] << { class: touched, attributes: watch }
      end
    end

  end

end