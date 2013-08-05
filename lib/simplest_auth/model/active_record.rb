module SimplestAuth
  module Model
    module ActiveRecord

      def self.included(base)
        base.send(:include, SimplestAuth::Model)
        base.extend(ClassMethods)
        base.extend(SimplestAuth::Callbacks)
      end

      module ClassMethods
        def find_matching_user(identifier_value)
          where(authentication_identifier => identifier_value).first
        end
      end

    end
  end
end