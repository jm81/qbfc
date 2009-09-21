require 'rubygems'
require 'rake'

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gem|
    gem.name = "qbfc"
    gem.rubyforge_project = "qbfc"
    gem.summary = "A wrapper around the QBFC COM object of the Quickbooks SDK"
    gem.email = "jmorgan@morgancreative.net"
    gem.homepage = "http://rubyforge.org/projects/qbfc/"
    gem.authors = ["Jared Morgan"]
    # gem is a Gem::Specification... see http://www.rubygems.org/read/chapter/20 for additional settings
  end
  
  rf = Jeweler::RubyforgeTasks.new
  rf.remote_doc_path = ''

rescue LoadError
  puts "Jeweler (or a dependency) not available. Install it with: sudo gem install jeweler"
end

require 'spec/rake/spectask'

QBFC_ROOT = File.dirname(__FILE__)

desc "Run all specs in spec/unit directory"
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'lib' << 'spec'
  spec.pattern = 'spec/unit/**/*_spec.rb'
  spec.spec_opts = ['--options', "\"#{QBFC_ROOT}/spec/spec.opts\""]
end

namespace :spec do
  desc "Run all specs in spec/unit directory with RCov"
  Spec::Rake::SpecTask.new(:rcov) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/unit/**/*_spec.rb'
    spec.spec_opts = ['--options', "\"#{QBFC_ROOT}/spec/spec.opts\""]
    spec.rcov = true
    spec.rcov_opts = lambda do
      IO.readlines("#{QBFC_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end
  
  desc "Run all specs in spec/integration directory"
  Spec::Rake::SpecTask.new(:integration) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/integration/**/*_spec.rb'
    spec.spec_opts = ['--options', "\"#{QBFC_ROOT}/spec/spec.opts\""]
  end
  
  desc "Run all specs in spec/integration directory with RCov"
  Spec::Rake::SpecTask.new(:integration_rcov) do |spec|
    spec.libs << 'lib' << 'spec'
    spec.pattern = 'spec/unit/**/*_spec.rb'
    spec.spec_opts = ['--options', "\"#{QBFC_ROOT}/spec/spec.opts\""]
    spec.rcov = true
    spec.rcov_opts = lambda do
      IO.readlines("#{QBFC_ROOT}/spec/rcov.opts").map {|l| l.chomp.split " "}.flatten
    end
  end

end

task :default => :spec

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  if File.exist?('VERSION')
    version = File.read('VERSION')
  else
    version = ""
  end

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "QBFC-Ruby #{version}"
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
