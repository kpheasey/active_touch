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
      @before_destroy_method = "touch_#{SecureRandom.uuid}"
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

      define_before_destroy
      add_active_record_callback(:before_destroy, @before_destroy_method, prepend: true)

      add_to_network
    end

    def define_before_commit_method
      association = @association
      options = @options

      @klass.send :define_method, @before_commit_method do |*args|
        changed_attributes = self.previous_changes.keys.map(&:to_sym)
        watched_changes = (options[:watch] & changed_attributes)

        if watched_changes.any? && options[:if].call(self) && !options[:unless].call(self)
          Rails.logger.debug "  Touch Before Commit: #{self.class}(#{self.id}) => #{association} due to changes in #{watched_changes}"
          Touch.new(self, association.to_s, touch_updates: options[:touch_updates]).perform
        end
      end
    end

    def define_after_commit_method
      association = @association
      options = @options

      @klass.send :define_method, @after_commit_method do |*args|
        changed_attributes = self.previous_changes.keys.map(&:to_sym)
        watched_changes = (options[:watch] & changed_attributes)

        if watched_changes.any? && options[:if].call(self) && !options[:unless].call(self)
          Rails.logger.debug "  Touch After Commit: #{self.class}(#{self.id}) => #{association} due to changes in #{watched_changes}"
          job_options = {
              after_touch: options[:after_touch].to_s,
              is_destroy: false,
              is_touched: options[:touch_in_transaction],
              touch_updates: options[:touch_updates]
          }

          if options[:async]
            TouchJob.set(queue: ActiveTouch.configuration.queue).perform_later(self, association.to_s, job_options)
          else
            Touch.new(self, association.to_s, job_options).perform
          end

        end
      end
    end

    def define_before_destroy
      association = @association
      options = @options

      @klass.send :define_method, @before_destroy_method do |*args|
        Rails.logger.debug "  Touch Before Destroy: #{self.class}(#{self.id}) => #{association} due to destroy"
        Touch.new(self, association.to_s, {
            after_touch: options[:after_touch].to_s,
            is_destroy: true,
            touch_updates: options[:touch_updates]
        }).perform
      end
    end

    def add_active_record_callback(event, method, args = {})
      @klass.send(event) { send(method, args) }
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
          unless: Proc.new { false },
          touch_updates: ActiveTouch.configuration.touch_updates
      }
    end

  end
end