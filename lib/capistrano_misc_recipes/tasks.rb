require 'rake'
require 'capistrano_misc_recipes/db_dump'

namespace :db do

  # optinoal parametrs
  #  store_path - path to store dump file
  #  dump_file  - file name
  #  without_timestamp - skip adding time stamp to file name if set to 'y'
  #  ignore_tables - do not dump given tables

  desc 'native SQL dump of database defined in config/database.yml for the current RAILS_ENV'
  task :sqldump => :environment do
    dump_database
  end

  namespace :sqldump do
    desc 'packed with gzip native SQL dump of database defined in config/database.yml for the current RAILS_ENV'
    task :gzip => :environment do
      dump_database 'gzip'
    end

    desc 'packed with bzip2 native SQL dump of database defined in config/database.yml for the current RAILS_ENV'
    task :bzip2 => :environment do
      dump_database 'bzip2'
    end
  end

  def dump_database pack=nil
    config = ActiveRecord::Base.configurations[Rails.env]

    raise "Destination directory do not exists" if !ENV['store_path'].blank? && !File.exists?(File.expand_path(ENV['store_path']))

    store_path = !ENV['store_path'].blank? ? File.expand_path(ENV['store_path']) : '.'
    dump_file  = !ENV['dump_file'].blank? ? ENV['dump_file'].dup : "#{`hostname`.chomp}-#{config['database']}"
    dump_file << '-' + Time.now.strftime('%Y-%m-%d-%H-%M-%S') unless !ENV['without_timestamp'].blank? && ENV['without_timestamp'].downcase == 'y'
    dump_file << '.sql'

    case pack
    when 'gzip'  ; dump_file << '.gz'
    when 'bzip2' ; dump_file << '.bz2'
    end
    file = File.expand_path(File.join(store_path, dump_file))

    command = ::CapistranoMiscRecipes::DbDump.command config.merge('pack' => pack, 'dump_file' => dump_file)

    puts command
    system command
  end
end
