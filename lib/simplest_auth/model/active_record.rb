module SimplestAuth
  module Model
    module ActiveRecord
      extend ActiveSupport::Concern

      included do
        include SimplestAuth::Model

        before_save :hash_password, :if => :password_required?
      end

      module ClassMethods

        def authenticate(email, password)
          found = where(:email => email).first
          (found && found.authentic?(password)) ? found : nil
        end

        def authenticate_by(attribute_name)
          instance_eval <<-EOM
            def authenticate(#{attribute_name}, password)
              found = where(:#{attribute_name} => #{attribute_name}).first
              (found && found.authentic?(password)) ? found : nil
            end
          EOM
        end

      end

    end
  end
end