module SimplestAuth
  module SessionsController
    extend ActiveSupport::Concern

    module ClassMethods

      def persist_authenticated(user_type)
        @user_type_to_persist = user_type.to_sym
      end

      def user_type_to_persist
        @user_type_to_persist || :user
      end

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

    def user_type_to_persist
      self.class.user_type_to_persist
    end

    def param_key
      session_class.model_name.param_key.to_sym
    end

    def sign_user_in_or_render(options = {})
      message      = options[:message] || I18n.t('simplest_auth.session.create')
      redirect_url = options[:url] || root_url

      @session = session_class.new(params[param_key])
      if @session.valid?
        send("current_#{user_type_to_persist}=", @session.user)

        self.flash[:notice] = message
        redirect_to redirect_url
      else
        render :new
      end
    end

    def sign_user_out(options = {})
      message      = options[:message] || I18n.t('simplest_auth.session.destroy')
      redirect_url = options[:url] || root_url

      send("log_out_#{user_type_to_persist}")

      flash[:notice] = message
      redirect_to redirect_url
    end

    def session_class
      self.class.session_class_name.constantize
    end

  end
end
