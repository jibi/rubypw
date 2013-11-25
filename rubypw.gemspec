Gem::Specification.new {|s|
	s.name = 'rubypw'
	s.version = '0.0.4'
	s.author = 'jibi'
	s.email = 'jibi@paranoici.org'
	s.homepage = 'http://github.com/jibi/rubypw'
	s.platform = Gem::Platform::RUBY
	s.summary = 'Just a stupid password manager that use AES256 to encrypt your credentials'
	s.description = '.'
	s.files = Dir['lib/**/*.rb']
	s.executables = 'rubypw'

	s.add_dependency 'ruport'
	s.add_dependency 'rqrcode'
	s.add_dependency 'chunky_png'
	s.add_dependency 'gtk'
}
