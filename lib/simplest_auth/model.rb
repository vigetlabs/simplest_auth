require 'simplest_auth/callbacks'

require 'simplest_auth/model/active_record'
require 'simplest_auth/model/data_mapper'
require 'simplest_auth/model/mongo_mapper'

module SimplestAuth
  module Model
    RecordNotFound = Class.new(StandardError) unless defined?(RecordNotFound)

    extend ActiveSupport::Concern

    included do
      attr_accessor :password, :password_confirmation
    end

    module ClassMethods
      def authentication_identifier
        @authentication_identifier || :email
      end

      def authenticate_by(identifier)
        @authentication_identifier = identifier.to_sym
      end

      def find_matching_user(identifier_value)
        first(authentication_identifier => identifier_value)
      end

      def authenticate(identifier_value, password)
        found = find_matching_user(identifier_value)
        (found && found.authentic?(password)) ? found : nil
      end

      def session_key
        :"#{name.underscore}_id"
      end
    end

    def authentic?(password)
      BCrypt::Password.new(self.crypted_password) == password rescue false
    end

    private

    def hash_password
      self.crypted_password = BCrypt::Password.create(self.password) if password_required?
    end

    def password_required?
      self.crypted_password.blank? || !self.password.blank?
    end

  end
end