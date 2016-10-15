module ActiveTouch
  class TouchJob < ActiveJob::Base

    attr_accessor :record, :association, :after_touch, :is_destroy, :is_touched, :touch_updates

    def perform(record, association, options = {})
      @record = record
      @association = association
      @after_touch = options[:after_touch]
      @is_destroy = options[:is_destroy]
      @is_touched = options[:is_touched]
      @touch_updates = (options[:touch_updates] || {})

      run
    end

    def run
      if !ActiveTouch.configuration.timestamp_attribute.nil?
        touch_updates[ActiveTouch.configuration.timestamp_attribute] = record.updated_at
      end

      if associated.is_a? ActiveRecord::Base
        associated.update_columns(touch_updates) if !touch_updates.empty? && !is_touched
        associated.send(after_touch) unless after_touch.blank?

      elsif !associated.nil?
        associated.update_all(touch_updates) if !touch_updates.empty? && !is_touched
        associated.each { |associate| associate.send(after_touch) } unless after_touch.blank?
      end
    end

    def associated
      @associated ||= begin
        if association == 'self'
          is_destroy || record.destroyed? ? nil : record
        else
          record.send(association)
        end
      end
    end
  end
end