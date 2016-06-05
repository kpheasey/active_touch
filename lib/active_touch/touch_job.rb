module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch, is_destroy = false)
      Touch.new(record, association, after_touch, is_destroy).run
    end

  end
end