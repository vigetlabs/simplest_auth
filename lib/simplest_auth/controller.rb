module SimplestAuth
  module Controller

    def self.included(base)
      base.extend(ClassMethods)
      base.send :helper_method, :authorized?
    end

    module ClassMethods
      def track_authenticated(*user_types)
        @user_types = user_types

        user_types.each do |user_type|
          define_method "current_#{user_type}" do
            ivar_name = "@current_#{user_type}"

            if !instance_variable_defined?(ivar_name)
              instance_variable_set(ivar_name, fetch_logged_in(:"#{user_type}"))
            end

            instance_variable_get(ivar_name) || send("log_out_#{user_type}")
          end

          define_method "current_#{user_type}=" do |user|
            session[session_key_for("#{user_type}")] = user.try(:id)
            instance_variable_set("@current_#{user_type}", user)
          end

          define_method "current_#{user_type}_id" do
            session[session_key_for("#{user_type}")]
          end

          define_method "#{user_type}_logged_in?" do
            !send("current_#{user_type}").nil?
          end

          define_method "log_out_#{user_type}" do
            session[session_key_for("#{user_type}")] = nil
            instance_variable_set("@current_#{user_type}", nil)
          end

          send(:helper_method, "current_#{user_type}", "#{user_type}_logged_in?")
        end

        def user_types
          @user_types
        end
      end
    end

    private

    def fetch_logged_in(user_type)
      resource_class = class_for(user_type)
      resource_id    = send("current_#{user_type}_id")

      if resource_id.present?
        resource_class.resource_for_id(resource_id)
      end
    end

    def class_for(user_type)
      user_type.to_s.classify.constantize
    end

    def session_key_for(user_type)
      class_for(user_type).session_key
    end

    def authorized?
      logged_in?
    end

    def access_denied
      store_location
      flash[:error] = login_message
      redirect_to new_session_url
    end

    def login_message
      "Login or Registration Required"
    end

    def store_location
      session[:return_to] = (request.respond_to?(:fullpath) ? request.fullpath : request.request_uri)
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def login_required
      authorized? || access_denied
    end

    def logged_in?
      self.class.user_types.any? {|t| send("#{t}_logged_in?") }
    end

  end
end