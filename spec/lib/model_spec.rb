require 'spec_helper'

describe User do

  describe ".session_key" do
    it "has a name based on the class name" do
      described_class.session_key.should == :user_id
    end
  end

  describe "#authentic?" do
    before do
      described_class.send(:include, SimplestAuth::Model)
      subject.stub(:crypted_password).and_return('abcdefg')
    end

    it "returns true when the supplied value matches the stored value" do
      password = double('password').tap {|p| p.stub(:==).with('password').and_return(true) }
      BCrypt::Password.stub(:new).with('abcdefg').and_return(password)

      subject.authentic?('password').should be(true)
    end

    it "returns fals when the supplied value does not match the stored value" do
      password = double('password').tap {|p| p.stub(:==).with('password').and_return(false) }
      BCrypt::Password.stub(:new).with('abcdefg').and_return(password)

      subject.authentic?('password').should be(false)
    end
  end

  describe "#password_required?" do
    it "is true when the crypted password is blank" do
      subject.stub(:crypted_password).and_return(double(:blank? => true))
      subject.send(:password_required?).should be(true)
    end

    it "is false when the crypted password is present" do
      subject.stub(:crypted_password).and_return(double(:blank? => false))
      subject.send(:password_required?).should be(false)
    end

    it "is true if a new password has been set" do
      subject.stub(:crypted_password).and_return(double(:blank? => false))
      subject.stub(:password).and_return(double(:blank? => false))

      subject.send(:password_required?).should be(true)
    end
  end

end