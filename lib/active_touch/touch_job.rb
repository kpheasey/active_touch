module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch, is_async = false)
      associated = association == 'self' ? record : record.send(association)

      if associated.is_a? ActiveRecord::Base
        associated.update_columns(updated_at: record.updated_at)
        associated.send(after_touch) unless after_touch.blank?

      elsif !associated.nil?

        0.step(associated.count, ActiveTouch.configuration.batch_size).each do |offset|
          batch = associated.offset(offset).limit(ActiveTouch.configuration.batch_size)
          batch.update_all(updated_at: record.updated_at)
          batch.each { |associate| associate.send(after_touch) } unless after_touch.blank?
        end
      end
    end

  end
end