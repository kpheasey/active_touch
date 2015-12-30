module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch, is_async = false)
      associated = association == 'self' ? record : record.send(association)

      if associated.is_a? ActiveRecord::Base
        associated.update_columns(updated_at: record.updated_at)
        associated.send(after_touch) unless after_touch.blank?

      elsif !associated.nil?

        if is_async
          # create a separate touch job for each associated record.
          # this helps avoid deadlocks
          associated.each do |associate|
            TouchJob
                .set(queue: ActiveTouch.configuration.queue)
                .perform_later(associate, 'self', after_touch, is_async)
          end

        else
          associated.update_all(updated_at: record.updated_at)
          associated.each { |associate| associate.send(after_touch) } unless after_touch.blank?
        end
      end
    end

  end
end