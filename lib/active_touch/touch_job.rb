module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch)
      associated = record.send(association)

      if associated.is_a? ActiveRecord::Base
        associated.update_columns(updated_at: record.updated_at)
        associated.send(after_touch) unless after_touch.blank?

      else
        associated.update_all(updated_at: record.updated_at)
        associated.each { |associate| associate.send(after_touch) } unless after_touch.blank?
      end
    end

  end
end