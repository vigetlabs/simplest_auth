module SimplestAuth
  module Session
    extend ActiveSupport::Concern

    included do
      include ActiveModel::Model

      attr_accessor :password
      validates :password, :presence => true

      validate :user_exists_for_credentials, :if => :credentials_supplied?
    end

    module ClassMethods
      def authentication_identifier(attribute_name)
        @authentication_identifier_attribute_name = attribute_name.to_sym

        attr_accessor @authentication_identifier_attribute_name
        validates @authentication_identifier_attribute_name, :presence => true
      end

      def authentication_identifier_attribute_name
        @authentication_identifier_attribute_name
      end

      def set_user_class_name(user_class_name)
        @user_class_name = user_class_name
      end

      def user_class_name
        @user_class_name || session_class_name_from_model || 'User'
      end

      def user_class
        user_class_name.constantize
      end

      def session_class_name_from_model
        name = to_s.sub(/Session$/, '')
        name.classify if name.present?
      end
    end

    def user_class
      self.class.user_class
    end

    def user
      @user ||= user_class.authenticate(authentication_identifier, password)
    end

    def persisted?
      false
    end

    private

    def authentication_identifier
      send(self.class.authentication_identifier_attribute_name)
    end

    def user_exists_for_credentials
      errors.add(:base, "#{user_class} not found for supplied credentials") unless user.present?
    end

    def credentials_supplied?
      authentication_identifier.present? && password.present?
    end
  end
end
