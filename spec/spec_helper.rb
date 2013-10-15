require 'rubygems'
require 'bundler/setup'

require 'active_model'

require File.dirname(__FILE__) + '/../lib/simplest_auth'

I18n.load_path += Dir["config/locales/*.yml"]

# Global dummy objects used in multiple tests

class Session
  include SimplestAuth::Session
  authentication_identifier :email
end

class BaseModel
  def self.inherited(other)
    other.send(:include, ActiveModel::Model)
  end

  def self.before_save(*args)
    #noop
  end
end

class User < BaseModel
  include SimplestAuth::Model::ActiveRecord
end
