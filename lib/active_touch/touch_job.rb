module ActiveTouch
  class TouchJob < ActiveJob::Base

    def perform(record, association, options = {})
      Touch.new(record, association, options).run
    end

  end
end