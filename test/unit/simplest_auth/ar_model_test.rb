require File.dirname(__FILE__) + '/../../test_helper'

class ARUser; end

class ARUserTest < Test::Unit::TestCase
  include BCrypt

  context "with ActiveRecord" do
    setup do
      ::ActiveRecord = Module.new
      ARUser.expects(:before_save).with(:hash_password, :if => :password_required?)
      ARUser.send(:include, SimplestAuth::Model)
    end

    context "the ARUser class" do
      should "redefine authenticate for AR" do
        ARUser.expects(:instance_eval).with(kind_of(String))
        ARUser.authenticate_by :email
      end

      should "have a default authenticate to email" do
        user = mock do |m|
          m.expects(:authentic?).with('password').returns(true)
        end

        ARUser.expects(:find_by_email).with('joe@schmoe.com').returns(user)
        assert_equal user, ARUser.authenticate('joe@schmoe.com', 'password')
      end

      context "with authenticate_by set to username" do
        setup do
          ARUser.authenticate_by :username
        end

        should "find a user with email for authentication" do
          user = mock do |m|
            m.expects(:authentic?).with('password').returns(true)
          end

          ARUser.expects(:find_by_username).with('joeschmoe').returns(user)
          assert_equal user, ARUser.authenticate('joeschmoe', 'password')
        end
      end
    end

    teardown do
      Object.send(:remove_const, ::ActiveRecord.to_s.to_sym)
    end
  end
end
