module SimplestAuth
  module Model
    module MongoMapper

      def self.included(base)
        base.send(:include, SimplestAuth::Model)
        base.extend(ClassMethods)

        base.extend(SimplestAuth::Callbacks)
      end

      module ClassMethods
        def resource_for_id(id)
          find(id)
        end
      end

    end
  end
end