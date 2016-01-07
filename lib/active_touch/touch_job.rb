module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch, is_async = ActiveTouch.configuration.async)
      associated = association == 'self' ? record : record.send(association)

      if associated.is_a? ActiveRecord::Base
        associated.update_columns(updated_at: record.updated_at)
        associated.send(after_touch) unless after_touch.blank?

      elsif !associated.nil?

        case ActiveTouch.configuration.touch_process

          when :batch_synchronous
            0.step(associated.count, ActiveTouch.configuration.batch_size).each do |offset|
              batch = associated.offset(offset).limit(ActiveTouch.configuration.batch_size)
              batch.update_all(updated_at: record.updated_at)
              batch.each { |associate| associate.send(after_touch) } unless after_touch.blank?
            end

          when :non_batch_asynchronous
            associated.each do |associate|
              TouchJob
                  .set(
                      queue: ActiveTouch.configuration.queue,
                      wait: ActiveTouch.configuration.associated_touch_delay.seconds
                  )
                  .perform_later(associate, 'self', after_touch, is_async)
            end

          when :non_batch_synchronous
            associated.update_all(updated_at: record.updated_at)
            associated.each { |associate| associate.send(after_touch) } unless after_touch.blank?
        end
      end
    end

  end
end