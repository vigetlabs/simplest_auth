require 'spec_helper'

class AdminSession
  include SimplestAuth::Session
end

class Admin
end

describe SimplestAuth::Session do

  describe ".user_class_name" do
    it "has a default value" do
      ::Session.user_class_name.should == 'User'
    end

    it "can be overridden" do
      OtherSession = Class.new do
        include SimplestAuth::Session
        set_user_class_name 'Admin'
      end

      OtherSession.user_class_name.should == 'Admin'
    end
  end

  describe ".user_class" do
    it "returns the appropriate class" do
      AdminSession.stub(:user_class_name).and_return('Admin')
      AdminSession.user_class.should == Admin
    end
  end

  describe "validations" do
    it "requires an email address" do
      subject = Session.new
      subject.valid?

      subject.errors[:email].should == ["can't be blank"]
    end

    it "requires a password" do
      subject = Session.new
      subject.valid?

      subject.errors[:password].should == ["can't be blank"]
    end

    it "does not set errors on base if there is no email or password" do
      subject = Session.new(:email => ' ', :password => ' ')
      subject.valid?

      subject.errors[:base].should be_empty
    end

    it "sets an error when there is no user" do
      subject = Session.new(:email => 'user@host.com', :password => 'password')
      User.stub(:authenticate).with('user@host.com', 'password').and_return(nil)

      subject.valid?
      subject.errors[:base].should == ["User not found for supplied credentials"]
    end

    it "does not set an error when there is a user" do
      subject = Session.new
      subject.stub(:user).with().and_return(User.new)

      subject.valid?
      subject.errors[:base].should be_empty
    end

  end

  describe "#email" do
    it "is nil by default" do
      Session.new.email.should be_nil
    end

    it "returns the set value" do
      subject = Session.new(:email => 'user@host.com')
      subject.email.should == 'user@host.com'
    end
  end

  describe "#password" do
    it "is nil by default" do
      Session.new.password.should be_nil
    end

    it "returns the set value" do
      subject = Session.new(:password => 'password')
      subject.password.should == 'password'
    end
  end

  describe "#user_class" do
    it "returns the constant from the class" do
      Session.new.user_class.should == User
    end
  end

  describe "#user" do
    it "knows there's no matching user" do
      User.stub(:authenticate).with('user@host.com', 'password').and_return(nil)

      subject = Session.new(:email => 'user@host.com', :password => 'password')
      subject.user.should be_nil
    end

    it "knows the matching user" do
      User.stub(:authenticate).with('user@host.com', 'password').and_return('user')

      subject = Session.new(:email => 'user@host.com', :password => 'password')
      subject.user.should == 'user'
    end
  end

end