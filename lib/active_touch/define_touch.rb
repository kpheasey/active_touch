module ActiveTouch
  class DefineTouch

    def self.on(klass, association, options)
      new(klass, association, options).define if ActiveRecord::Base.connection.data_source_exists?(klass.table_name)
    rescue ActiveRecord::NoDatabaseError
      # do nothing
    end

    def initialize(klass, association, options)
      @klass = klass
      @association = association
      @options = default_options.merge(options)
      @before_commit_method = "touch_#{SecureRandom.uuid}"
      @after_commit_method = "touch_#{SecureRandom.uuid}"
      @destroy_touch_method = "touch_#{SecureRandom.uuid}"
    end

    def define
      if @options[:touch_in_transaction]
        define_before_commit_method
        add_active_record_callback(:before_commit, @before_commit_method)
      end

      if !@options[:touch_in_transaction] || !@options[:after_touch].nil?
        define_after_commit_method
        add_active_record_callback(:after_commit, @after_commit_method)
      end

      define_destroy_touch_method
      add_active_record_callback(:after_destroy, @destroy_touch_method)

      add_to_network
    end

    def define_before_commit_method
      association = @association
      options = @options

      @klass.send :define_method, @before_commit_method do |*args|
        changed_attributes = self.previous_changes.keys.map(&:to_sym)
        watched_changes = (options[:watch] & changed_attributes)

        # watched values changed and conditional procs evaluate to true
        if watched_changes.any? && options[:if].call(self) && !options[:unless].call(self)
          Rails.logger.debug "Touch: #{self.class}(#{self.id}) => #{association} due to changes in #{watched_changes}"
          TouchJob.perform_now(self, association.to_s, nil, false, options[:touch_in_transaction])
        end
      end
    end

    def define_after_commit_method
      association = @association
      options = @options

      @klass.send :define_method, @after_commit_method do |*args|
        changed_attributes = self.previous_changes.keys.map(&:to_sym)
        watched_changes = (options[:watch] & changed_attributes)

        # watched values changed and conditional procs evaluate to true
        if watched_changes.any? && options[:if].call(self) && !options[:unless].call(self)
          Rails.logger.debug "Touch: #{self.class}(#{self.id}) => #{association} due to changes in #{watched_changes}"

          if options[:async]
            TouchJob
                .set(queue: ActiveTouch.configuration.queue)
                .perform_later(self, association.to_s, options[:after_touch].to_s, false, options[:touch_in_transaction])

          else
            TouchJob.perform_now(self, association.to_s, options[:after_touch].to_s, false, options[:touch_in_transaction])
          end

        end
      end
    end

    def define_destroy_touch_method
      association = @association
      options = @options

      @klass.send :define_method, @destroy_touch_method do |*args|
        Rails.logger.debug "Touch: #{self.class}(#{self.id}) => #{association} due to destroy"
        TouchJob.perform_now(self, association.to_s, options[:after_touch].to_s, true)
      end
    end

    def add_active_record_callback(event, method)
      @klass.send(event) { send(method) }
    end

    def add_to_network
      touched = @options[:class_name] || @association.to_s.camelize
      ActiveTouch.network.add_touch(@klass.to_s, touched, @options[:watch])
    end

    def default_options
      {
          touch_in_transaction: ActiveTouch.configuration.touch_in_transaction,
          async: ActiveTouch.configuration.async,
          watch: @klass.column_names.map(&:to_sym) - ActiveTouch.configuration.ignored_attributes,
          after_touch: nil,
          if: Proc.new { true },
          unless: Proc.new { false }
      }
    end

  end
end