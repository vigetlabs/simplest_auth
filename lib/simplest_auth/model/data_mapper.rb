module SimplestAuth
  module Model
    module DataMapper

      def self.included(base)
        base.send(:include, SimplestAuth::Model)
        base.before(:save) { hash_password if password_required? }
      end

    end
  end
end