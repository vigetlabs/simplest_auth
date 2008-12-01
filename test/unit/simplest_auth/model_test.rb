require File.dirname(__FILE__) + '/../../test_helper'

class User
  include SimplestAuth::Model
end

class UserTest < Test::Unit::TestCase
  context "the User class" do
    should "find a user by email for authentication" do
      user_stub = stub()
      user_stub.stubs(:authentic?).with('password').returns(true)
      User.stubs(:find_by_email).with('joe@schmoe.com').returns(user_stub)
      
      assert_equal user_stub, User.authenticate('joe@schmoe.com', 'password')
    end
  end
  
  context "an instance of the User class" do
    
  end
end
