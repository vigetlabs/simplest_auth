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

class Student
end

class CustomSession
  include SimplestAuth::Session
  authentication_identifier :email
end

class CustomSessionsController
  include SimplestAuth::SessionsController
  include DummyController

  persist_authenticated :student

  def create
    sign_user_in_or_render(:message => 'Hi', :url => '/admin')
  end

  def destroy
    sign_user_out(:message => 'Bye', :url => '/survey')
  end
end

class OtherSessionsController
  include SimplestAuth::SessionsController

  set_session_class_name 'CustomSession'
end

describe SimplestAuth::SessionsController do
  describe "#session_class" do
    it "returns the default session class" do
      subject = SessionsController.new
      subject.send(:session_class).should == Session
    end

    it "knows the value based on the controller name" do
      subject = CustomSessionsController.new
      subject.send(:session_class).should == CustomSession
    end

    it "can be overridden by the user" do
      subject = OtherSessionsController.new
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

          new_session.stub(:user)
          subject.stub(:flash).with().and_return(flash)

          subject.create
        end

        it "redirects" do
          new_session.stub(:user)

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
        subject.should_receive(:log_out_user).with()
        subject.destroy
      end

      it "sets the flash" do
        flash = double('flash').tap {|f| f.should_receive(:[]=).with(:notice, 'You have signed out') }
        subject.stub(:flash).with().and_return(flash)

        subject.stub(:log_out_user)

        subject.destroy
      end

      it "redirects" do
        subject.stub(:log_out_user)
        subject.should_receive(:redirect_to).with('/')
        subject.destroy
      end
    end

  end

  describe "requests for CustomSessionsController" do
    let!(:new_session) { ::CustomSession.new }

    subject { ::CustomSessionsController.new }

    describe "#create" do
      it "assigns to @session with a key based on the session class" do
        ::CustomSession.stub(:new).with('key' => 'value').and_return(new_session)
        subject.stub(:params).with().and_return(:custom_session => {'key' => 'value'})

        subject.create

        subject.instance_variable_get(:@session).should == new_session
      end
    end

    context "with a valid user session" do
      before do
        new_session.stub(:user).and_return(double('user'))
        new_session.stub(:valid?).and_return(true)

        ::CustomSession.stub(:new).and_return(new_session)
      end

      describe "#create" do
        it "stores the current user" do
          student = Student.new
          new_session.stub(:user).with().and_return(student)

          subject.should_receive(:current_student=).with(student)

          subject.create
        end

        it "sets the flash" do
          flash = double('flash').tap {|f| f.should_receive(:[]=).with(:notice, 'Hi') }
          subject.stub(:flash).with().and_return(flash)

          subject.stub(:current_student=)

          subject.create
        end

        it "redirects" do
          subject.stub(:current_student=)
          subject.should_receive(:redirect_to).with('/admin')
          subject.create
        end
      end

      describe "#destroy" do
        it "removes the user from session" do
          subject.should_receive(:log_out_student).with()
          subject.destroy
        end

        it "sets the flash" do
          flash = double('flash').tap {|f| f.should_receive(:[]=).with(:notice, 'Bye') }
          subject.stub(:flash).with().and_return(flash)

          subject.stub(:log_out_student)

          subject.destroy
        end

        it "redirects" do
          subject.stub(:log_out_student)
          subject.should_receive(:redirect_to).with('/survey')

          subject.destroy
        end
      end
    end

  end
end