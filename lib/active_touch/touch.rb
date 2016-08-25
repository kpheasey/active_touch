module ActiveTouch
  class Touch

    attr_accessor :record, :association, :after_touch, :is_destroy, :is_touched

    def initialize(record, association, after_touch, is_destroy = false, is_touched = false)
      @record = record
      @association = association
      @after_touch = after_touch
      @is_destroy = is_destroy
      @is_touched = is_touched
    end

    def run
      if associated.is_a? ActiveRecord::Base
        if !ActiveTouch.configuration.timestamp_attribute.nil? && !is_touched
          associated.update_columns(ActiveTouch.configuration.timestamp_attribute => record.updated_at)
        end

        associated.send(after_touch) unless after_touch.blank?

      elsif !associated.nil? && !associated.empty?
        if !ActiveTouch.configuration.timestamp_attribute.nil? && !is_touched
          associated.update_all(ActiveTouch.configuration.timestamp_attribute => record.updated_at)
        end

        associated.each { |associate| associate.send(after_touch) } unless after_touch.blank?
      end
    end

    def associated
      @associated ||= begin
        if association == 'self'
          is_destroy ? nil : record
        else
          record.send(association)
        end
      end
    end

  end
end