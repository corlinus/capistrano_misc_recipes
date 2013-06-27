# Recipe for fetch db dump from server

require 'yaml'
require 'erb'
require 'capistrano_misc_recipes/db_dump'

module Capistrano
  module Console
    Configuration.instance(true).load do

      desc 'fetch db dump from the server'
      task :dbfetch, roles: :db, only: { primary: true } do

        # TODO extract main loginc to lib to reuse in rake task

        database_yml = capture "cat #{current_path}/config/database.yml"
        config = begin
                  YAML.load(ERB.new(database_yml).result)[rails_env]
                 rescue
                   # TODO error report if database.yml not reachable!
                 end

        dump_file = "/tmp/#{ capture("hostname").chomp }-#{ config['database'] }-#{ Time.now.strftime('%Y-%m-%d-%H-%M-%S') }.sql.bz2"

        on_rollback { run "rm -f #{dump_file}" }

        dump_command = ::CapistranoMiscRecipes::DbDump.command(config.merge 'dump_file' => dump_file, 'pack' => 'bzip2' )

        puts dump_command
        run dump_command
        download dump_file, File.basename(dump_file)
        run "rm -f #{dump_file}"
      end

    end
  end
end
