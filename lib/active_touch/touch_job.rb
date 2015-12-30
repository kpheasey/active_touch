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

        # attempt to update all records 3 times.  Dead locks are common when
        # multiple related touches are triggered at the same time.  A randomized
        # delay of up to 3 seconds between retries is used to prevent the error from
        # being raised
        begin
          retries ||= 0
          associated.update_all(updated_at: record.updated_at)

        rescue ActiveRecord::StatementInvalid
          if retries < 3
            sleep(rand(3) + 1)
            retries += 1
            retry
          else
            raise
          end
        end


        associated.each { |associate| associate.send(after_touch) } unless after_touch.blank?
      end
    end

  end
end