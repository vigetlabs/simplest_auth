require File.expand_path('../../../test_helper', __FILE__)

module DummyController
  def params
    {}
  end

  def current_user=(user)
  end

  def flash
    Hash.new
  end

  def redirect_to(path)
  end

  def render(action)
  end

  def root_url
    '/'
  end
end

class SessionsController
  include SimplestAuth::SessionsController
  include DummyController
end

class CustomSession
end

class CustomSessionsController
  include SimplestAuth::SessionsController
  include DummyController

  set_session_class_name 'CustomSession'

  def create
    sign_user_in_or_render(:message => 'Hi', :url => '/admin')
  end
end

class SimplestAuth::SessionsControllerTest < Test::Unit::TestCase

  context "An instance of the SessionsController" do
    should "know the default session class" do
      assert_equal Session, SessionsController.new.send(:session_class)
    end

    should "be able to override the session class that is used" do
      controller = CustomSessionsController.new
      assert_equal CustomSession, controller.send(:session_class)
    end
  end

  context "Requests" do
    setup do
      @controller = ::SessionsController.new
      @session    = ::Session.new
    end

    context "a GET to :new" do

      should "assign to @session" do
        ::Session.stubs(:new).with().returns(@session)

        @controller.new

        assert_equal @session, @controller.instance_variable_get(:@session)
      end
    end

    context "a POST to :create" do
      should "assign to @session" do
        ::Session.stubs(:new).with('key' => 'value').returns(@session)
        @controller.stubs(:params).with().returns(:session => {'key' => 'value'})

        @controller.create

        assert_equal @session, @controller.instance_variable_get(:@session)
      end

      context "when successful" do
        setup do
          @session.stubs(:valid?).with().returns(true)
          ::Session.stubs(:new).returns(@session)
        end

        should "save the user in session when successful" do
          user = User.new
          @session.stubs(:user).with().returns(user)

          @controller.expects(:current_user=).with(user)

          @controller.create
        end

        should "set the flash when successful" do
          flash = mock()
          flash.expects(:[]=).with(:notice, 'You have signed in successfully')
          @controller.stubs(:flash).with().returns(flash)

          @controller.create
        end

        should "redirect when successful" do
          @controller.expects(:redirect_to).with('/')
          @controller.create
        end
      end

      context "when unsuccessful" do
        setup do
          @session.stubs(:valid?).with().returns(false)
          ::Session.stubs(:new).returns(@session)
        end

        should "render when unsuccessful" do
          @controller.expects(:render).with(:new)
          @controller.create
        end

        should "not redirect when unsuccessful" do
          @controller.expects(:redirect_to).never
          @controller.create
        end
      end
    end

    context "a POST to :create with a customized controller" do
      setup do
        @session = ::CustomSession.new
        @session.stubs(:user).returns(stub())
        @session.stubs(:valid?).returns(true)

        ::CustomSession.stubs(:new).returns(@session)

        @controller = CustomSessionsController.new
      end

      should "set the appropriate flash message" do
        flash = mock()
        flash.expects(:[]=).with(:notice, 'Hi')

        @controller.stubs(:flash).with().returns(flash)

        @controller.create
      end

      should "redirect to the specified URL" do
        @controller.expects(:redirect_to).with('/admin')

        @controller.create
      end
    end

  end

end