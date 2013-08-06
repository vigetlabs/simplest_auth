require 'spec_helper'

class Teacher < BaseModel
  include SimplestAuth::Model::ActiveRecord
end

class Administrator < BaseModel
  include SimplestAuth::Model::ActiveRecord
end

class Controller
  def self.helper_method(*method_names)
    # noop
  end

  def new_session_url
    '/login'
  end
end

class BasicController < ::Controller
  include SimplestAuth::Controller

  track_authenticated :user
end

class CustomController < ::Controller
  include SimplestAuth::Controller

  track_authenticated :teacher, :administrator
end

describe BasicController do

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

  describe "#current_user" do
    it "returns the current user" do
      User.stub(:resource_for_id).with('1').and_return('user')
      subject.stub(:current_user_id).and_return('1')

      subject.send(:current_user).should == 'user'
    end

    it "clears the session for the current user if it doesn't exist" do
      User.stub(:resource_for_id).with('1').and_return(nil)
      subject.stub(:current_user_id).with().and_return('1')

      subject.should_receive(:log_out_user)

      subject.send(:current_user)
    end

    it "returns nil for the current user if it doesn't exist" do
      User.stub(:resource_for_id).with('1').and_return(nil)
      subject.stub(:current_user_id).with().and_return('1')
      subject.stub(:log_out_user)

      subject.send(:current_user).should be_nil
    end
  end

  describe "#current_user_id" do
    it "is fetched from session" do
      subject.stub(:session).and_return({:user_id => 1})
      subject.send(:current_user_id).should == 1
    end
  end

  describe "#user_logged_in?" do
    it "returns true when a user is logged in" do
      subject.stub(:current_user).and_return('user')
      subject.send(:user_logged_in?).should be(true)
    end

    it "returns false when a user is not logged in" do
      subject.stub(:current_user).and_return(nil)
      subject.send(:user_logged_in?).should be(false)
    end
  end

  describe "#logged_in?" do
    it "returns true when a user is logged in" do
      subject.stub(:user_logged_in?).and_return(true)
      subject.send(:logged_in?).should be(true)
    end

    it "returns false when a user is not logged in" do
      subject.stub(:user_logged_in?).and_return(false)
      subject.send(:logged_in?).should be(false)
    end
  end

  describe "#authorized?" do
    it "returns true if the user is logged in" do
      subject.stub(:logged_in?).and_return(true)
      subject.send(:authorized?).should be(true)
    end
  end

  describe "#log_out_user" do
    it "clears the session variable" do
      session = double('session').tap {|s| s.should_receive(:[]=).with(:user_id, nil) }
      subject.stub(:session).and_return(session)

      subject.send(:log_out_user)
    end

    it "returns nil" do
      session = double('session').tap {|s| s.stub(:[]=).with(:user_id, nil) }
      subject.stub(:session).and_return(session)

      subject.send(:log_out_user).should be_nil
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

end

describe CustomController do

  describe "#current_teacher=" do
    let(:teacher) { double('teacher', :id => 1) }

    it "stores the teacher's ID in session" do
      session = double('session').tap {|s| s.should_receive(:[]=).with(:teacher_id, 1) }
      subject.stub(:session).and_return(session)

      subject.send(:current_teacher=, teacher)
    end

    it "saves the current teacher to avoid lookup" do
      subject.stub(:session).and_return({})

      subject.send(:current_teacher=, teacher)
      subject.send(:current_teacher).should == teacher
    end
  end

  describe "#current_administrator=" do
    let(:administrator) { double('administrator', :id => 2) }

    it "stores the administrator's ID in session" do
      session = double('session').tap {|s| s.should_receive(:[]=).with(:administrator_id, 2) }
      subject.stub(:session).and_return(session)

      subject.send(:current_administrator=, administrator)
    end

    it "saves the current teacher to avoid lookup" do
      subject.stub(:session).and_return({})

      subject.send(:current_administrator=, administrator)
      subject.send(:current_administrator).should == administrator
    end
  end

  describe "#current_teacher" do
    it "returns the current teacher" do
      Teacher.stub(:resource_for_id).with('1').and_return('teacher')
      subject.stub(:current_teacher_id).and_return('1')

      subject.send(:current_teacher).should == 'teacher'
    end

    it "clears the session for the current teacher if it doesn't exist" do
      Teacher.stub(:resource_for_id).with('1').and_return(nil)
      subject.stub(:current_teacher_id).with().and_return('1')

      subject.should_receive(:log_out_teacher)

      subject.send(:current_teacher)
    end

    it "returns nil for the current teacher if it doesn't exist" do
      Teacher.stub(:resource_for_id).with('1').and_return(nil)
      subject.stub(:current_teacher_id).with().and_return('1')
      subject.stub(:log_out_teacher)

      subject.send(:current_teacher).should be_nil
    end
  end

  describe "#current_administrator" do
    it "returns the current administrator" do
      Administrator.stub(:resource_for_id).with('1').and_return('administrator')
      subject.stub(:current_administrator_id).and_return('1')

      subject.send(:current_administrator).should == 'administrator'
    end

    it "clears the session for the current administrator if it doesn't exist" do
      Administrator.stub(:resource_for_id).with('1').and_return(nil)
      subject.stub(:current_administrator_id).with().and_return('1')

      subject.should_receive(:log_out_administrator)

      subject.send(:current_administrator)
    end

    it "returns nil for the current administrator if it doesn't exist" do
      Administrator.stub(:resource_for_id).with('1').and_return(nil)
      subject.stub(:current_administrator_id).with().and_return('1')
      subject.stub(:log_out_administrator)

      subject.send(:current_administrator).should be_nil
    end
  end

  describe "#teacher_logged_in?" do
    it "returns true when a teacher is logged in" do
      subject.stub(:current_teacher).and_return('teacher')
      subject.send(:teacher_logged_in?).should be(true)
    end

    it "returns false when a teacher is not logged in" do
      subject.stub(:current_teacher).and_return(nil)
      subject.send(:teacher_logged_in?).should be(false)
    end
  end

  describe "#administrator_logged_in?" do
    it "returns true when a administrator is logged in" do
      subject.stub(:current_administrator).and_return('administrator')
      subject.send(:administrator_logged_in?).should be(true)
    end

    it "returns false when a administrator is not logged in" do
      subject.stub(:current_administrator).and_return(nil)
      subject.send(:administrator_logged_in?).should be(false)
    end
  end

  describe "#log_out_teacher" do
    it "clears the session variable" do
      session = double('session').tap {|s| s.should_receive(:[]=).with(:teacher_id, nil) }
      subject.stub(:session).and_return(session)

      subject.send(:log_out_teacher)
    end

    it "returns nil" do
      session = double('session').tap {|s| s.stub(:[]=).with(:teacher_id, nil) }
      subject.stub(:session).and_return(session)

      subject.send(:log_out_teacher).should be_nil
    end
  end

  describe "#log_out_administrator" do
    it "clears the session variable" do
      session = double('session').tap {|s| s.should_receive(:[]=).with(:administrator_id, nil) }
      subject.stub(:session).and_return(session)

      subject.send(:log_out_administrator)
    end

    it "returns nil" do
      session = double('session').tap {|s| s.stub(:[]=).with(:administrator_id, nil) }
      subject.stub(:session).and_return(session)

      subject.send(:log_out_administrator).should be_nil
    end
  end

  describe "#current_teacher_id" do
    it "is fetched from session" do
      subject.stub(:session).and_return({:teacher_id => 1})
      subject.send(:current_teacher_id).should == 1
    end
  end

  describe "#current_administrator_id" do
    it "is fetched from session" do
      subject.stub(:session).and_return({:administrator_id => 1})
      subject.send(:current_administrator_id).should == 1
    end
  end

  describe "#logged_in?" do
    it "is false when no one is logged in" do
      subject.stub(:teacher_logged_in?).and_return(false)
      subject.stub(:administrator_logged_in?).and_return(false)

      subject.send(:logged_in?).should be(false)
    end

    it "is true when a teacher is logged in" do
      subject.stub(:teacher_logged_in?).and_return(true)
      subject.stub(:administrator_logged_in?).and_return(false)

      subject.send(:logged_in?).should be(true)
    end

    it "is true when an administrator is logged in" do
      subject.stub(:teacher_logged_in?).and_return(false)
      subject.stub(:administrator_logged_in?).and_return(true)

      subject.send(:logged_in?).should be(true)
    end

    it "is true when both a teacher and administrator are logged in" do
      subject.stub(:teacher_logged_in?).and_return(true)
      subject.stub(:administrator_logged_in?).and_return(true)

      subject.send(:logged_in?).should be(true)
    end
  end

end