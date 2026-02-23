# naga_freeagent_tasks.rake
namespace :naga_freeagent do
  namespace :install do
    desc "Copy NagaFreeagent migrations to the host application's db/migrate directory"
    task :migrations do
      if Rake::Task.task_defined?("railties:install:migrations")
        Rake::Task["railties:install:migrations"].invoke
      else
        puts "Rake task 'railties:install:migrations' not found. This may happen if you're not running in a Rails environment."
      end
    end
  end
end
