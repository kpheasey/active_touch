module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, after_touch = nil, is_destroy = false, is_touched = false)
      Touch.new(record, association, after_touch, is_destroy, is_touched).run
    end

  end
end