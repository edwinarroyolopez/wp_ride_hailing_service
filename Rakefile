require 'sequel'
require 'sequel/extensions/migration'
require 'rake'

namespace :db do
  task :connect do
    require_relative 'config/database'
  end

  desc 'Run migrations'
  task migrate: :connect do
    version = 5 # DB.tables.empty? ? 0 : DB.tables.length - 1
    Sequel::Migrator.run(DB, 'db/migrations', target: version, allow_missing_migration_files: true)
    puts "Created migration: #{version}"
  end
    
  desc 'Roll back the last migration'
  task rollback: :connect do
    Sequel::Migrator.run(DB, 'db/migrations', target: 4)
  end
  
end