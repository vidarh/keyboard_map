require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc "Install bundle"
task :bundle do
  system("bundle install --path=./vendor/bundle")
end

