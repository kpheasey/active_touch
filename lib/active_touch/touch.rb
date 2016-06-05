module ActiveTouch
  class Touch

    attr_accessor :record, :association, :after_touch, :is_destroy

    def initialize(record, association, after_touch, is_destroy = false)
      @record = record
      @association = association
      @after_touch = after_touch
      @is_destroy = is_destroy
    end

    def run
      if associated.is_a? ActiveRecord::Base
        unless ActiveTouch.configuration.timestamp_attribute.nil?
          associated.update_columns(ActiveTouch.configuration.timestamp_attribute => record.updated_at)
        end

        associated.send(after_touch) unless after_touch.blank?

      elsif !associated.nil? && !associated.empty?
        unless ActiveTouch.configuration.timestamp_attribute.nil?
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