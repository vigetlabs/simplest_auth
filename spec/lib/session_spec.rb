require 'spec_helper'

Admin = Class.new

class AdminSession
  include SimplestAuth::Session
  authentication_identifier :email
end

class OtherSession
  include SimplestAuth::Session
  set_user_class_name 'Admin'
  authentication_identifier :username
end

describe ::Session do

  describe ".user_class_name" do
    it "has a default value" do
      ::Session.user_class_name.should == 'User'
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

describe AdminSession do
  describe ".user_class" do
    it "returns the appropriate class" do
      described_class.user_class.should == Admin
    end
  end
end

describe OtherSession do

  describe ".user_class_name" do
    it "knows the configured value" do
      described_class.user_class_name.should == 'Admin'
    end
  end

  describe "validations" do
    it "requires a username" do
      subject = described_class.new
      subject.valid?

      subject.errors[:username].should == ["can't be blank"]
    end

    it "does not set errors on base if there is no username or password" do
      subject = described_class.new(:username => ' ', :password => ' ')
      subject.valid?

      subject.errors[:base].should be_empty
    end

    it "sets an error when there is no user" do
      subject = described_class.new(:username => 'username', :password => 'password')
      Admin.stub(:authenticate).with('username', 'password').and_return(nil)

      subject.valid?
      subject.errors[:base].should == ["Admin not found for supplied credentials"]
    end

    it "does not set an error when there is a user" do
      described_class.stub(:user).with().and_return(Admin.new)

      subject.valid?
      subject.errors[:base].should be_empty
    end
  end
end
