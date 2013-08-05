module SimplestAuth
  module Callbacks
    def self.extended(base)
      base.before_save :hash_password, :if => :password_required?
    end
  end
end