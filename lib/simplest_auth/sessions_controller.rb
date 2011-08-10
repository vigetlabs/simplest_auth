module SimplestAuth
  module SessionsController
    extend ActiveSupport::Concern

    module ClassMethods

      def set_session_class_name(session_class_name)
        @session_class_name = session_class_name
      end

      def session_class_name
        @session_class_name || 'Session'
      end

    end

    module InstanceMethods

      def new
        @session = session_class.new
      end

      def create
        sign_user_in_or_render
      end

      private

      def sign_user_in_or_render(options = {})
        message      = options[:message] || 'You have signed in successfully'
        redirect_url = options[:url] || root_url

        @session = session_class.new(params[:session])
        if @session.valid?
          self.current_user = @session.user
          flash[:notice] = message
          redirect_to redirect_url
        else
          render :new
        end
      end

      def session_class
        self.class.session_class_name.constantize
      end

    end

  end
end
