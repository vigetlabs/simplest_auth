require 'spec_helper'
require 'active_record'

class ARUser
  def self.before_save(*args); end

  include ActiveModel::Model
  include SimplestAuth::Model::ActiveRecord
end

describe ARUser do

  describe ".authenticate" do
    it "returns the matching user for the supplied email and password" do
      user = double('user').tap do |u|
        u.stub(:first).and_return(u)
        u.stub(:authentic?).with('password').and_return(true)
      end

      described_class.stub(:where).with(:email => 'user@host.com').and_return(user)

      described_class.authenticate('user@host.com', 'password').should == user
    end

    it "returns the matching user for the supplied username and password" do
      described_class.authenticate_by :username

      user = double('user').tap do |u|
        u.stub(:first).and_return(u)
        u.stub(:authentic?).with('password').and_return(true)
      end

      described_class.stub(:where).with(:username => 'someuser').and_return(user)

      described_class.authenticate('someuser', 'password').should == user
    end

    it "returns nil when there is no matching user" do
      user = double('user', :first => nil)
      described_class.stub(:where).with(:username => 'someuser').and_return(user)

      described_class.authenticate('someuser', 'password').should be_nil
    end
  end

  describe ".resource_for_id" do
    it "fetches the resource" do
      described_class.stub(:find_by_id).with(1).and_return('user')
      described_class.resource_for_id(1).should == 'user'
    end

    it "returns nil when it can't find the resource" do
      described_class.stub(:find_by_id).with(1).and_return(nil)
      described_class.resource_for_id(1).should be_nil
    end
  end

end