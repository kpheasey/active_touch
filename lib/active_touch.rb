require 'active_support/concern'
require 'active_job/base'
require 'active_record/base'

require 'active_touch/configuration'
require 'active_touch/touch'
require 'active_touch/define_touch'
require 'active_touch/network'
require 'active_touch/touch_job'
require 'active_touch/version'

module ActiveTouch
  extend ActiveSupport::Concern

  module ClassMethods

    def touch(association, options = {})
      DefineTouch.on(self, association, options)
    end

  end
end

class ActiveRecord::Base
  include ActiveTouch
end