module ActiveTouch
  class TouchJob < ActiveJob::Base

    attr_accessor :record, :association, :after_touch, :is_destroy, :is_touched, :touch_updates

    def perform(record, association, options = {})
      Touch.new(record, association, options).perform
    end

  end
end