module SimplestAuth
  module Model
    module MongoMapper
      extend ActiveSupport::Concern

      included do
        include SimplestAuth::Model

        before_save :hash_password, :if => :password_required?
      end

      module ClassMethods
        def authenticate(email, password)
          found = first(:email => email)
          (found && found.authentic?(password)) ? found : nil
        end

        def authenticate_by(attribute_name)
          instance_eval <<-EOM
            def authenticate(#{attribute_name}, password)
              found = first(:#{attribute_name} => #{attribute_name})
              (found && found.authentic?(password)) ? found : nil
            end
          EOM
        end
      end

    end
  end
end