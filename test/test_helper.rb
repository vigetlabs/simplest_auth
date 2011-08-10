require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

require 'active_model'

require File.dirname(__FILE__) + '/../lib/simplest_auth'

# Global dummy objects used in multiple tests

class Session
  include SimplestAuth::Session
end

class User
  def self.authenticate(email, password)
  end
end
