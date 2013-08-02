require 'spec_helper'

DMUser = Class.new

describe DMUser do

  before do
    described_class.stub(:active_record?).and_return(false)
    described_class.stub(:data_mapper?).and_return(true)
    described_class.stub(:before)
    described_class.send(:include, SimplestAuth::Model)
  end

  describe ".authenticate" do
    it "returns the matching user for the supplied email and password" do
      user = double('user').tap {|u| u.stub(:authentic?).with('password').and_return(true) }
      described_class.stub(:first).with(:email => 'user@host.com').and_return(user)

      described_class.authenticate('user@host.com', 'password').should == user
    end

    it "returns the matching user for the supplied username and password" do
      DMUser.authenticate_by :username

      user = double('user').tap {|u| u.stub(:authentic?).with('password').and_return(true) }
      described_class.stub(:first).with(:username => 'someuser').and_return(user)

      described_class.authenticate('someuser', 'password').should == user
    end

    it "returns nil when there is no matching user"
  end

end