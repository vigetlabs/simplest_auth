module SimplestAuth
  module Model
    def self.included(base)
      base.extend ClassMethods
      base.send(:include, InstanceMethods)

      base.class_eval do
        attr_accessor :password, :password_confirmation
      end

      if base.data_mapper?
        base.class_eval do
          before(:save) {hash_password if password_required?}
        end
      elsif base.active_record? || base.mongo_mapper?
        base.class_eval do
          before_save :hash_password, :if => :password_required?
        end
      end
    end

    module ClassMethods
      def active_record?
        defined?(ActiveRecord) && ancestors.include?(ActiveRecord::Base)
      end

      def data_mapper?
        defined?(DataMapper) && ancestors.include?(DataMapper::Resource)
      end

      def mongo_mapper?
        defined?(MongoMapper) && ancestors.include?(MongoMapper::Document)
      end

      def authenticate(email, password)
        if active_record?
          found = where(:email => email).first
        elsif data_mapper? || mongo_mapper?
          found = first(:email => email)
        end

        (found && found.authentic?(password)) ? found : nil
      end

      def authenticate_by(ident)
        if active_record?
          instance_eval <<-EOM
            def authenticate(#{ident}, password)
              found = where(:#{ident} => #{ident}).first
              (found && found.authentic?(password)) ? found : nil
            end
          EOM
        elsif data_mapper? || mongo_mapper?
          instance_eval <<-EOM
            def authenticate(#{ident}, password)
              found = first(:#{ident} => #{ident})
              (found && found.authentic?(password)) ? found : nil
            end
          EOM
        end
      end

      def session_key
        if name.to_s.respond_to?(:underscore)
          "#{name.underscore}_id".to_sym
        else
          "#{name.downcase}_id".to_sym
        end
      end
    end

    module InstanceMethods
      include BCrypt

      RecordNotFound = Class.new(StandardError) unless defined?(RecordNotFound)

      def authentic?(password)
        Password.new(self.crypted_password) == password rescue false
      end

      private
      def hash_password
        self.crypted_password = Password.create(self.password) if password_required?
      end

      def password_required?
        self.crypted_password.blank? || !self.password.blank?
      end
    end
  end
end