module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch, is_async = ActiveTouch.configuration.async)
      associated = association == 'self' ? record : record.send(association)

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

  end
end