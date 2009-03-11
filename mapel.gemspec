# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{mapel}
  s.version = "0.1.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Aleksander Williams"]
  s.date = %q{2009-03-11}
  s.description = %q{A dead-simple image-rendering DSL.}
  s.email = %q{alekswilliams@earthlink.net}
  s.files = ["Rakefile", "README.rdoc", "lib/mapel.rb", "spec/fixtures", "spec/fixtures/ImageMagick.jpg", "spec/spec_helper.rb", "spec/output", "spec/mapel_spec.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/akdubya/mapel}
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A dead-simple image-rendering DSL.}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
