module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch)
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
          associate.update_columns(updated_at: record.updated_at)
          associate.send(after_touch) unless after_touch.blank?
        end
      end
    end

  end
end