begin
  require 'bcrypt'
rescue LoadError
  begin
    gem 'bcrypt-ruby'
  rescue Gem::LoadError
    puts "Please install the bcrypt-ruby gem"
  end
end

# SimplestAuth
require 'simplest_auth/version'
require 'simplest_auth/model'
require 'simplest_auth/controller'
require 'simplest_auth/sessions_controller'
require 'simplest_auth/session'

module SimplestAuth
  spec = Gem::Specification.find_by_name("simplest_auth")
  I18n.load_path += Dir.glob(File.join(spec.gem_dir, "config", "locales", "*.yml"))
end
