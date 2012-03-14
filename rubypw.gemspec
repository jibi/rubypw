Gem::Specification.new {|s|
	s.name = 'rubypw'
	s.version = '0.0.1'
	s.author = 'jcjh'
	s.email = 'jcjh@paranoici.org'
	s.homepage = 'http://github.com/jcjh/rubypw'
	s.platform = Gem::Platform::RUBY
	s.summary = 'Just a stupid password manager that use aes to encrypt your credentials'
	s.description = '.'
	s.files = Dir['lib/**/*.rb']
	s.executables = 'rubypw'

	s.add_dependency 'ruport'
	s.add_dependency 'rqrcode'
	s.add_dependency 'chunky_png'
}
