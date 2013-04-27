unless defined?(Cucumber)
  def World(mod)
    RSpec.configure{ |config| config.include(mod) }
  end
end

Dir["#{File.expand_path(File.dirname(__FILE__))}/helpers/**/*.rb"].map do |file|
  require file
end
