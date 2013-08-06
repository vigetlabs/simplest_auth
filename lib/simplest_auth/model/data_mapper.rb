module SimplestAuth
  module Model
    module DataMapper

      def self.included(base)
        base.send(:include, SimplestAuth::Model)
        base.extend(ClassMethods)

        base.before(:save) { hash_password if password_required? }
      end

      module ClassMethods
        def resource_for_id(id)
          get(id)
        end
      end

    end
  end
end