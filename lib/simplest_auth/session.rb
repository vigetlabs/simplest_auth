module SimplestAuth
  module Session

    def self.included(other)
      other.class_eval do
        include InstanceMethods
        extend ClassMethods
        include ActiveModel::Validations

        attr_accessor :email, :password

        validates :email, :presence => true
        validates :password, :presence => true

        validate :user_exists_for_credentials
      end
    end

    module ClassMethods
      def set_user_class_name(user_class_name)
        @user_class_name = user_class_name
      end

      def user_class_name
        @user_class_name || name.demodulize.sub(/Session$/, '')
      end

      def user_class
        user_class_name.constantize
      end
    end

    module InstanceMethods
      def initialize(attributes = {})
        attributes.each {|k,v| send("#{k}=", v) }
      end

      def user_class
        self.class.user_class
      end

      def user
        @user ||= user_class.authenticate(email, password)
      end

      private

      def user_exists_for_credentials
        errors.add(:base, "#{user_class} not found for supplied credentials") unless user.present?
      end
    end

  end
end