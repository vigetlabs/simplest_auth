require 'spec_helper'

class User
  class RecordNotFound < StandardError; end
  def self.session_key
    :user_id
  end
end

class Controller
  include SimplestAuth::Controller

  def new_session_url
    '/login'
  end
end

describe SimplestAuth::Controller do
  subject { Controller.new }

  describe "#authorized?" do
    it "returns true if the user is logged in" do
      subject.stub(:logged_in?).and_return(true)
      subject.send(:authorized?).should be(true)
    end

  end

  describe "#access_denied" do
    it "redirects to the login page" do
      subject.stub(:store_location)
      subject.stub(:flash).and_return({})

      subject.should_receive(:redirect_to).with('/login')

      subject.send(:access_denied)
    end

    it "sets the error flash" do
      subject.stub(:store_location)
      subject.stub(:redirect_to)

      flash = double('flash').tap {|f| f.should_receive(:[]=).with(:error, 'Login or Registration Required') }
      subject.stub(:flash).and_return(flash)

      subject.send(:access_denied)
    end

    it "stores the location of the desired page before redirecting" do
      subject.stub(:redirect_to)
      subject.stub(:flash).and_return({})

      subject.should_receive(:store_location)

      subject.send(:access_denied)
    end
  end

  describe "#store_location" do
    it "stores the location of the current request" do
      request_uri = '/posts/1'

      request = double('request', :request_uri => request_uri)
      session = double('session').tap {|s| s.should_receive(:[]=).with(:return_to, request_uri) }

      subject.stub(:request).with().and_return(request)
      subject.stub(:session).with().and_return(session)

      subject.send(:store_location)
    end
  end

  describe "#redirect_back_or_default" do
    it "redirects back to the stored URI" do
      subject.stub(:session).and_return({:return_to => '/somewhere'})
      subject.should_receive(:redirect_to).with('/somewhere')

      subject.send(:redirect_back_or_default, nil)
    end

    it "redirect to the specified location if there is no URI in session" do
      subject.stub(:session).and_return({})
      subject.should_receive(:redirect_to).with('default')

      subject.send(:redirect_back_or_default, 'default')
    end

    it "clears the session stored url after redirect" do
      session = {:return_to => 'somewhere'}

      subject.stub(:session).and_return(session)
      subject.stub(:redirect_to)

      subject.send(:redirect_back_or_default, nil)

      session[:return_to].should be_nil
    end
  end

  describe "#login_required" do
    it "knows that login is required from authorized method" do
      subject.stub(:authorized?).and_return(true)
      subject.send(:login_required).should be(true)
    end

    it "denies access if login is required and not authorized" do
      subject.stub(:authorized?).and_return(false)
      subject.should_receive(:access_denied)

      subject.send(:login_required)
    end
  end

  describe "#logged_in?" do
    it "returns true when a user is logged in" do
      subject.stub(:current_user_id).and_return(1)
      subject.send(:logged_in?).should be(true)
    end

    it "returns false when a user is not logged in" do
      subject.stub(:current_user_id).and_return(nil)
      subject.send(:logged_in?).should be(false)
    end
  end

  describe "#current_user" do
    it "returns the current user via #get" do
      user_class = double('user class').tap {|u| u.stub(:get).with('1').and_return('user') }

      subject.stub(:current_user_id).and_return('1')
      subject.stub(:user_class).and_return(user_class)

      subject.send(:current_user).should == 'user'
    end

    it "returns the current user via #find when #get fails" do
      user_class = double('user_class').tap do |u|
        u.stub(:where).with(:id => '1').and_return(u)
        u.stub(:first).and_return('user')
      end

      subject.stub(:current_user_id).and_return('1')
      subject.stub(:user_class).and_return(user_class)

      subject.send(:current_user).should == 'user'
    end

    it "clears the session and returns nil for the current user if it doesn't exist" do
      user_class = double('user_class').tap do |u|
        u.stub(:where).with(:id => '1').and_return(u)
        u.stub(:first).and_return(nil)
      end

      subject.stub(:current_user_id).with().and_return('1')
      subject.stub(:user_class).and_return(user_class)

      subject.should_receive(:clear_session)
      subject.send(:current_user).should be_nil
    end
  end

  describe "#clear_session" do
    it "clears the session variable" do
      session = double('session').tap {|s| s.should_receive(:[]=).with(:user_id, nil) }
      subject.stub(:session).and_return(session)

      subject.send(:clear_session)
    end
  end

  describe "#current_user=" do
    let(:user) { double('user', :id => 1) }

    it "stores the user's ID in session" do
      session = double('session').tap {|s| s.should_receive(:[]=).with(:user_id, 1) }
      subject.stub(:session).and_return(session)

      subject.send(:current_user=, user)
    end

    it "saves the current user to avoid lookup" do
      subject.stub(:session).and_return({})

      subject.send(:current_user=, user)
      subject.send(:current_user).should == user
    end
  end

  describe "#current_user_id" do
    it "is fetched from session" do
      subject.stub(:session).and_return({:user_id => 1})
      subject.send(:current_user_id).should == 1
    end
  end

  describe "#session_key" do
    it "uses the value from the model class" do
      user_class = double('user_class', :session_key => :user_id)
      subject.stub(:user_class).and_return(user_class)

      subject.send(:session_key).should == :user_id
    end
  end

end