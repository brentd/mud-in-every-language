desc "Run the tests"
task :test do
  project_dir = task.application.original_dir
  exec("ruby spec/lib/runner.rb")
end

task :default => [:test]
