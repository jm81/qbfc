require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
gem 'rspec'
require 'spec/rake/spectask'

QBFC_ROOT = File.dirname(__FILE__)

task :default => :spec

desc "Run all specs in spec/unit directory"
Spec::Rake::SpecTask.new(:spec) do |t|
  t.spec_opts = ['--options', "\"#{QBFC_ROOT}/spec/spec.opts\""]
  t.spec_files = FileList['spec/unit/**/*_spec.rb']
end

namespace :spec do
  desc "Run all specs in spec/unit directory with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |t|
    t.spec_opts = ['--options', "\"#{QBFC_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/unit/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("#{QBFC_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end
  
  desc "Run all specs in spec/integration directory"
  Spec::Rake::SpecTask.new(:integration) do |t|
    t.spec_opts = ['--options', "\"#{QBFC_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/integration/**/*_spec.rb']
  end

  desc "Run all specs in spec/integration directory with RCov"
  Spec::Rake::SpecTask.new(:integration_rcov) do |t|
    t.spec_opts = ['--options', "\"#{QBFC_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/integration/**/*_spec.rb']
    t.rcov = true
    t.rcov_opts = lambda do
      IO.readlines("#{QBFC_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end
  
  desc "Print Specdoc for all specs"
  Spec::Rake::SpecTask.new(:doc) do |t|
    t.spec_opts = ["--format", "specdoc", "--dry-run"]
    t.spec_files = FileList['spec/**/*_spec.rb']
  end
end

desc 'Generate documentation for the qbfc library.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'QBFC-Ruby'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

spec = Gem::Specification.new do |s|
  s.name = "qbfc"
  s.version = "0.2.0"
  s.author = "Jared Morgan"
  s.email = "jmorgan@morgancreative.net"
  s.homepage = "http://rubyforge.org/projects/qbfc/"
  s.rubyforge_project = "qbfc"
  s.platform = Gem::Platform::CURRENT
  s.summary = "A wrapper around the QBFC COM object of the Quickbooks SDK"
  s.files = FileList['lib/**/*.rb', 'bin/*', '[A-Z]*', 'spec/*.opts', 'spec/*.rb', 'spec/unit/**/*'].to_a
  s.require_path = "lib"
  s.test_files = Dir.glob('spec/unit/**/*_spec.rb')
  s.has_rdoc = true
  s.extra_rdoc_files = ["README"]
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end