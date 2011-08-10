require File.expand_path('../../../test_helper', __FILE__)

class AdminSession
  include SimplestAuth::Session
end

class Admin
end

class SimplestAuth::SessionTest < Test::Unit::TestCase

  context "The Session class" do
    should "have a default value for the user class name" do
      assert_equal 'User', ::Session.user_class_name
    end

    should "know the user class name when it's set" do
      OtherSession = Class.new do
        include SimplestAuth::Session
        set_user_class_name 'Admin'
      end
      assert_equal 'Admin', OtherSession.user_class_name
    end

    should "know the user class" do
      AdminSession.stubs(:user_class_name).with().returns('Admin')
      assert_equal Admin, AdminSession.user_class
    end
  end

  context "An instance of the Session class" do
    should "not have an email by default" do
      assert_nil Session.new.email
    end

    should "not have a password by default" do
      assert_nil Session.new.password
    end

    should "know the email address when set" do
      session = Session.new(:email => 'user@host.com')
      assert_equal 'user@host.com', session.email
    end

    should "know the password when set" do
      session = Session.new(:password => 'password')
      assert_equal 'password', session.password
    end

    should "require an email to be present" do
      session = Session.new
      session.valid?

      assert_equal ["can't be blank"], session.errors[:email]
    end

    should "require the password to be present" do
      session = Session.new
      session.valid?

      assert_equal ["can't be blank"], session.errors[:password]
    end

    should "know the user class" do
      session = Session.new
      assert_equal User, session.user_class
    end

    should "know that there's no user" do
      User.stubs(:authenticate).with('user@host.com', 'password').returns(nil)

      session = Session.new(:email => 'user@host.com', :password => 'password')
      assert_nil session.user
    end

    should "know that there's a user" do
      User.stubs(:authenticate).with('user@host.com', 'password').returns('user')

      session = Session.new(:email => 'user@host.com', :password => 'password')
      assert_equal 'user', session.user
    end

    should "set an error when there is no user" do
      session = Session.new
      session.stubs(:user).with().returns(nil)

      session.valid?
      assert_equal ["User not found for supplied credentials"], session.errors[:base]
    end

    should "not set an error when there is a user" do
      session = Session.new
      session.stubs(:user).with().returns(User.new)

      session.valid?
      assert_equal [], session.errors[:base]
    end
  end

end