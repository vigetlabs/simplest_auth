require 'bcrypt'

module SimplestAuth
  module Model
    def self.included(base)
      base.extend ClassMethods
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        attr_accessor :password, :password_confirmation
      end
      
      if defined?(ActiveRecord)
        base.class_eval do
          before_create :hash_password
        end
      elsif defined?(DataMapper)
        base.class_eval do
          before :save, :hash_password
        end
      end
    end
    
    module ClassMethods
      def authenticate_by(ident)
        if defined?(ActiveRecord)
          instance_eval <<-EOM
            def authenticate(#{ident}, password)
              klass = find_by_#{ident}(#{ident})
              (klass && klass.authentic?(password)) ? klass : nil
            end
          EOM
        elsif defined?(DataMapper)
          instance_eval <<-EOM
            def authenticate(#{ident}, password)
              klass = first(:#{ident} => #{ident})
              (klass && klass.authentic?(password)) ? klass : nil
            end
          EOM
        end
      end
      
      def authenticate(email, password)
        if defined?(ActiveRecord)
          klass = find_by_email(email)
        elsif defined?(DataMapper)
          klass = first(:email => email)
        end
        
        (klass && klass.authentic?(password)) ? klass : nil
      end
    end
    
    module InstanceMethods
      include BCrypt
      
      def authentic?(password)
        Password.new(self.crypted_password) == password
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