module SimplestAuth
  module Model
    def self.included(base)
      base.send(:extend, ClassMethods)
      base.send(:include, InstanceMethods)
    end
    
    module ClassMethods
      def authenticate(email, password)
        klass = find_by_email(email)
        (klass && klass.authentic?(password)) ? klass : nil
      end
    end
    
    module InstanceMethods
      # def authentic?(password)
      #   Password.new(self.crypted_password) == password
      # end

      private  
      # def hash_password
      #   self.crypted_password = Password.create(self.password)
      # end
      # 
      # def password_required?
      #   self.crypted_password.blank? || !self.password.blank?
      # end
    end
  end
end