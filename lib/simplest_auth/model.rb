require 'bcrypt'

module SimplestAuth
  module Model
    def self.included(base)
      base.extend ClassMethods
      base.send(:include, InstanceMethods)
      
      base.class_eval do
        attr_accessor :password, :password_confirmation
        
        before_create :hash_password
      end
    end
    
    module ClassMethods
      def authenticate_by(ident)
        instance_eval <<-EOM
          def authenticate(#{ident}, password)
            klass = find_by_#{ident}(#{ident})
            (klass && klass.authentic?(password)) ? klass : nil
          end
        EOM
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