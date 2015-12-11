module ActiveTouch
  class DefineTouch

    def self.on(klass, association, options)
      new(klass, association, options).define
    end

    def initialize(klass, association, options)
      @klass = klass
      @association = association
      @options = default_options.merge(options)
      @touch_method = "touch_#{SecureRandom.uuid}"
    end

    def define
      define_touch_method
      add_active_record_callback
    end

    def define_touch_method
      association = @association
      options = @options

      @klass.send :define_method, @touch_method do |*args|
        changed_attributes = self.previous_changes.keys.map(&:to_sym)

        if (options[:attributes] & changed_attributes).any?

          if options[:async]
            TouchJob.perform_later(self, association.to_s, options[:after_touch].to_s)
          else
            TouchJob.perform_now(self, association.to_s, options[:after_touch].to_s)
          end

        end
      end
    end

    def add_active_record_callback
      touch_method = @touch_method
      @klass.send(:after_commit) { send(touch_method) }
    end

    def default_options
      {
          async: false,
          attributes: @klass.column_names.map(&:to_sym),
          after_touch: nil
      }
    end

  end
end