require 'spec_helper'

ARUser = Class.new

describe ARUser do

  before do
    described_class.stub(:active_record?).and_return(true)
    described_class.stub(:before_save)
    described_class.send(:include, SimplestAuth::Model)
  end

  describe ".authenticate" do
    it "returns the matching user for the supplied email and password" do
      user = double('user').tap do |u|
        u.stub(:first).and_return(u)
        u.stub(:authentic?).with('password').and_return(true)
      end

      ARUser.stub(:where).with(:email => 'user@host.com').and_return(user)

      described_class.authenticate('user@host.com', 'password').should == user
    end

    it "returns the matching user for the supplied username and password" do
      ARUser.authenticate_by :username

      user = double('user').tap do |u|
        u.stub(:first).and_return(u)
        u.stub(:authentic?).with('password').and_return(true)
      end

      ARUser.stub(:where).with(:username => 'someuser').and_return(user)

      described_class.authenticate('someuser', 'password').should == user
    end

    it "returns nil when there is no matching user"
  end

end