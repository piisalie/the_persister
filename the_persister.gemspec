Gem::Specification.new do |s|
  s.name        = 'the_persister'
  s.version     = '0.1.0'
  s.license    = 'MIT'
  s.summary     = 'A featureless and tiny layer for interacting with fake and real databases.'
  s.authors     = ["Paul Dawson"]
  s.email       = 'paul@sqint.co'
  s.homepage    = 'https://github.com/piisalie/the_persister'

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})
  s.require_paths = ["lib"]

  s.add_dependency 'pg', '~> 0.18.1'

  s.add_development_dependency 'minitest', '~> 5.6.1'
end
