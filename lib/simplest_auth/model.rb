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