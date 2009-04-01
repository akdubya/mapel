require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'fileutils'

task :default => [:test]
task :spec => :test

name = 'mapel'
version = '0.1.4'

spec = Gem::Specification.new do |s|
  s.name = name
  s.version = version
  s.summary = "A dead-simple image-rendering DSL."
  s.description = "A dead-simple image-rendering DSL."
  s.author = "Aleksander Williams"
  s.email = "alekswilliams@earthlink.net"
  s.homepage = "http://github.com/akdubya/mapel"
  s.platform = Gem::Platform::RUBY
  s.has_rdoc = true
  s.files = %w(Rakefile README.rdoc) + Dir.glob("{lib,spec}/**/*")
  s.require_path = "lib"
end

Rake::GemPackageTask.new(spec) do |p|
  p.need_tar = true if RUBY_PLATFORM !~ /mswin/
end

desc "Install as a system gem"
task :install => [ :package ] do
  sh %{sudo gem install pkg/#{name}-#{version}.gem}
end

desc "Uninstall as a system gem"
task :uninstall => [ :clean ] do
  sh %{sudo gem uninstall #{name}}
end

desc "Create a gemspec file"
task :make_spec do
  File.open("#{name}.gemspec", "w") do |file|
    file.puts spec.to_ruby
  end
end

Rake::TestTask.new(:test) do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/*_spec.rb']
  t.verbose = true
end

Rake::RDocTask.new do |t|
  t.rdoc_dir = 'rdoc'
  t.title = "Mapel: A dead-simple image-rendering DSL."
  t.options << '--line-numbers' << '--inline-source' << '-A cattr_accessor=object'
  t.options << '--charset' << 'utf-8'
  t.rdoc_files.include('README.rdoc')
  t.rdoc_files.include('lib/mapel.rb')
end