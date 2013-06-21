# Recipes for run somoe useful console commands on server

module Capistrano
  module Console
    Configuration.instance(true).load do

      def execute_ssh_locally cmd=''
        hostname = find_servers_for_task(current_task).first
        local_ssh_command = ["ssh"]
        local_ssh_command << "-l #{user}" if fetch(:user, nil)
        local_ssh_command << hostname
        local_ssh_command << "-p #{port}" if fetch(:port, nil)
        local_ssh_command << "-t 'cd #{current_path}#{ cmd != '' ? ' && ' + cmd : '' }'"
        local_ssh_command = local_ssh_command.join " "

        logger.trace "executing locally: #{local_ssh_command.inspect}" if logger
        system local_ssh_command

        if $?.to_i > 0 # $? is command exit code (posix style)
          raise Capistrano::CommandError, "Command '#{cmd}' returned status code #{$?}"
        end
      end

      namespace :console do

        desc "Open shell console the firs app server"
        task :shell, roles: :app do
          execute_ssh_locally 'exec $SHELL'
        end

        desc "Open a rails console the first app server"
        task :rails, roles: :app do

          console_command = "rails console %s" % rails_env
          console_command = "bundle exec #{console_command}" if defined? Bundler

          execute_ssh_locally console_command
        end

        desc "Open a rails db console the first app server"
        task :db, roles: :app do
          console_command = "rails dbconsole %s" % rails_env
          console_command = "bundle exec #{console_command}" if defined? Bundler

          execute_ssh_locally console_command
        end

        desc "tail -f log file"
        task :tail_log, roles: :app do
          console_command = "tail -f log/#{rails_env}.log"
          execute_ssh_locally console_command
        end

        desc "tail 1000 lines from log file"
        task :tail_log1000, roles: :app do
          console_command = "tail -1000 log/#{rails_env}.log"
          execute_ssh_locally console_command
        end

      end
    end
  end
end

