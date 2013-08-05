module SimplestAuth
  module Model
    module MongoMapper

      def self.included(base)
        base.send(:include, SimplestAuth::Model)
        base.extend(SimplestAuth::Callbacks)
      end

    end
  end
end