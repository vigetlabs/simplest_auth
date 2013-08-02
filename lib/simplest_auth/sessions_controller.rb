module SimplestAuth
  module SessionsController
    extend ActiveSupport::Concern

    module ClassMethods

      def set_session_class_name(class_name)
        @session_class_name = class_name
      end

      def session_class_name
        @session_class_name || session_class_name_from_controller
      end

      def session_class_name_from_controller
        to_s.sub(/Controller$/, '').classify
      end

    end

    def new
      @session = session_class.new
    end

    def create
      sign_user_in_or_render
    end

    def destroy
      sign_user_out
    end

    private

    def param_key
      session_class.model_name.param_key.to_sym
    end

    def sign_user_in_or_render(options = {})
      message      = options[:message] || 'You have signed in successfully'
      redirect_url = options[:url] || root_url

      @session = session_class.new(params[param_key])
      if @session.valid?
        self.current_user = @session.user
        flash[:notice] = message
        redirect_to redirect_url
      else
        render :new
      end
    end

    def sign_user_out(options = {})
      message      = options[:message] || 'You have signed out'
      redirect_url = options[:url] || root_url

      self.current_user = nil
      flash[:notice] = message
      redirect_to redirect_url
    end

    def session_class
      self.class.session_class_name.constantize
    end

  end
end
