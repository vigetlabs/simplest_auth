unless defined?(ActiveModel::Model)

  # Ripped from ActiveModel::Model 4.1.1
  # https://github.com/rails/rails/blob/v4.1.1/activemodel/lib/active_model/model.rb
  #
  module ActiveModel
    module Model
      def self.included(base)
        base.class_eval do
          extend  ActiveModel::Naming
          extend  ActiveModel::Translation
          include ActiveModel::Validations
          include ActiveModel::Conversion
        end
      end

      def initialize(params={})
        params.each do |attr, value|
          self.public_send("#{attr}=", value)
        end if params

        super()
      end

      def persisted?
        false
      end
    end
  end
end
