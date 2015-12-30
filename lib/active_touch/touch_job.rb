module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch, is_async)
      if association == 'self'
        associated = record
      else
        associated = record.send(association)
      end

      if associated.is_a? ActiveRecord::Base
        associated.update_columns(updated_at: record.updated_at)
        associated.send(after_touch) unless after_touch.blank?

      elsif !associated.nil?
        associated.each do |associate|

          if is_async
            TouchJob
                .set(queue: ActiveTouch.configuration.queue)
                .perform_later(associate, 'self', after_touch, is_async)
          else
            TouchJob.perform_later(associate, 'self', after_touch, is_async)
          end
        end
      end
    end

  end
end