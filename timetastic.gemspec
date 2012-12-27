Gem::Specification.new do |s|
  s.name        = 'timetastic'
  s.version     = '0.1.0'
  s.summary     = "Utility collection of relative date selectors similar to ActiveRecord's."
  s.description = "Pure Ruby date selection using an easy and readable interface. " +
                  "Calculation of dates accounts for wrapping across days, months, and years."
  s.authors     = ["Ahmad Amireh"]
  s.email       = 'ahmad@algollabs.com'
  s.files       = Dir.glob("lib/**/*.rb")
  s.homepage    = 'https://github.com/amireh/timetastic'

  s.add_development_dependency 'rspec'
end
