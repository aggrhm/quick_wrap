unless defined?(Motion::Project::Config)
  raise "This file must be required within a RubyMotion project Rakefile."
end

#BW.require(File.join(File.dirname(__FILE__), 'quick_wrap/*.rb'))

Motion::Project::App.setup do |app|
  Dir.glob(File.join(File.dirname(__FILE__), 'quick_wrap/layouts/*.rb')).each do |file|
    app.files.unshift(file)
  end
  Dir.glob(File.join(File.dirname(__FILE__), 'quick_wrap/cells/*.rb')).each do |file|
    app.files.unshift(file)
  end
  Dir.glob(File.join(File.dirname(__FILE__), 'quick_wrap/views/*.rb')).each do |file|
    app.files.unshift(file)
  end
  Dir.glob(File.join(File.dirname(__FILE__), 'quick_wrap/libs/*.rb')).each do |file|
    app.files.unshift(file)
  end
  Dir.glob(File.join(File.dirname(__FILE__), 'quick_wrap/core/*.rb')).each do |file|
    app.files.unshift(file)
  end
end
