require 'spec_helper'

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

  def destroy
    sign_user_out(:message => 'Bye', :url => '/survey')
  end
end

describe SimplestAuth::SessionsController do
  describe "#session_class" do
    it "returns the default session class" do
      subject = SessionsController.new
      subject.send(:session_class).should == Session
    end

    it "allows the session class to be overridden" do
      subject = CustomSessionsController.new
      subject.send(:session_class).should == CustomSession
    end
  end

  describe "requests for SessionsController" do
    let!(:new_session) { ::Session.new }

    subject { ::SessionsController.new }

    describe "#new" do
      it "assigns to @session" do
        ::Session.stub(:new).with().and_return(new_session)

        subject.new

        subject.instance_variable_get(:@session).should == new_session
      end
    end

    describe "#create" do

      it "assigns to @session" do
        ::Session.stub(:new).with('key' => 'value').and_return(new_session)
        subject.stub(:params).with().and_return(:session => {'key' => 'value'})

        subject.create

        subject.instance_variable_get(:@session).should == new_session
      end

      context "when successful" do
        before do
          new_session.stub(:valid?).with().and_return(true)
          ::Session.stub(:new).and_return(new_session)
        end

        it "stores the current user" do
          user = User.new
          new_session.stub(:user).with().and_return(user)

          subject.should_receive(:current_user=).with(user)

          subject.create
        end

        it "sets the flash" do
          flash = double('flash')
          flash.should_receive(:[]=).with(:notice, 'You have signed in successfully')

          subject.stub(:flash).with().and_return(flash)

          subject.create
        end

        it "redirects" do
          subject.should_receive(:redirect_to).with('/')
          subject.create
        end
      end

      context "when unsuccessful" do
        before do
          new_session.stub(:valid?).with().and_return(false)
          ::Session.stub(:new).and_return(new_session)
        end

        it "renders" do
          subject.should_receive(:render).with(:new)
          subject.create
        end

        it "does not redirect" do
          subject.should_receive(:redirect_to).never
          subject.create
        end
      end

    end

    describe "#destroy" do
      it "removes the user from session" do
        subject.should_receive(:current_user=).with(nil)
        subject.destroy
      end

      it "sets the flash" do
        flash = double('flash')
        flash.should_receive(:[]=).with(:notice, 'You have signed out')

        subject.stub(:flash).with().and_return(flash)
        subject.destroy
      end

      it "redirects" do
        subject.should_receive(:redirect_to).with('/')
        subject.destroy
      end
    end

  end

  describe "requests for CustomSessionsController" do
    let!(:new_session) { ::CustomSession.new }

    subject { ::CustomSessionsController.new }

    before do
      new_session.stub(:user).and_return(double('user'))
      new_session.stub(:valid?).and_return(true)

      ::CustomSession.stub(:new).and_return(new_session)
    end

    describe "#create" do
      it "sets the flash" do
        flash = double('flash').tap {|f| f.should_receive(:[]=).with(:notice, 'Hi') }

        subject.stub(:flash).with().and_return(flash)
        subject.create
      end

      it "redirects" do
        subject.should_receive(:redirect_to).with('/admin')
        subject.create
      end
    end

    describe "#destroy" do
      it "sets the flash" do
        flash = double('flash').tap {|f| f.should_receive(:[]=).with(:notice, 'Bye') }

        subject.stub(:flash).with().and_return(flash)
        subject.destroy
      end

      it "redirects" do
        subject.should_receive(:redirect_to).with('/survey')
        subject.destroy
      end
    end

  end
end