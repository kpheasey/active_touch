module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch, is_async = ActiveTouch.configuration.async)
      associated = association == 'self' ? record : record.send(association)

      if associated.is_a? ActiveRecord::Base
        associated.update_columns(ActiveTouch.timestamp_attribute => record.updated_at) unless ActiveTouch.timestamp_attribute.nil?
        associated.send(after_touch) unless after_touch.blank?

      elsif !associated.nil? && !associated.empty?
        associated.update_all(ActiveTouch.timestamp_attribute => record.updated_at) unless ActiveTouch.timestamp_attribute.nil?
        associated.each { |associate| associate.send(after_touch) } unless after_touch.blank?
      end
    end

  end
end