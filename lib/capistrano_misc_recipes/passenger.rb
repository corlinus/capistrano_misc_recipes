# Recipe for manage passenger

require 'capistrano_misc_recipes/bundler'

module Capistrano
  module Passenger
    Configuration.instance(true).load do
      namespace :passenger do
        extend ::CapistranoMiscRecipes::Bundler

        _cset :passenger_pids_dir,    Pathname.new(current_path).join('tmp', 'pids')
        _cset :passenger_pid_file,    passenger_pids_dir.join("#{rails_env}.pid")
        _cset :passenger_socket_file, passenger_pids_dir.join("#{rails_env}.sock")
        _cset :passenger_address,     '127.0.0.1'
        _cset :passenger_port,        3000
        _cset :passenger_use_socket,  false

        # command to start passenger
        def start_command
          # TODO try_sudo

          command = []
          command << "cd #{current_path}"
          command << "&&"
          command << "rm -f #{passenger_socket_file}" # if passenger was finished ubnormally
          command << "&&"
          command << "#{bundlify 'passenger'} start"
          command << current_path

          if fetch :passenger_use_socket
            command << "--socket #{passenger_socket_file}"
          else
            command << "--address #{passenger_address}"
            command << "--port #{passenger_port}"
          end

          command << "--pid-file #{passenger_pid_file}"
          command << "--environment #{rails_env}"
          command << "--daemonize"
          command.join ' '
        end

        def stop_command
          # TODO try_sudo
          "cd #{current_path} && #{bundlify 'passenger'} stop --pid-file #{passenger_pid_file} ; true"
        end

        def restart_command
          "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
        end

        desc '[internal] Start passenger'
        task :start, roles: :app do
          run start_command
        end

        desc '[internal] Stop passenger'
        task :stop, roles: :app do
          run stop_command
        end

        desc '[internal] Restart passenger'
        task :restart, roles: :app, except: { no_release: true } do
          run restart_command
        end

        namespace :config do

          {
            god: { extension: 'god' },
            nginx: { extension: nil}
          }.each do |key, data|

            desc "generates nginx #{key} file"
            task key do
              template_dir = Pathname.new(File.dirname(__FILE__)).join 'templates'
              app_name     = [application, exists?(:stages) ? stage : nil].compact.join(?_)
              file_name    = [app_name, data[:extension]].compact.join ?.
              conf_file    = ERB.new(File.read(template_dir.join "#{key}.erb"), nil, '-').result binding

              puts conf_file
              # save file in application tmp dir
              put conf_file, File.join(current_path, 'tmp', file_name).to_s
            end

          end

        end

      end

      namespace :deploy do
        desc 'Starts application server'
        task :start do
          passenger.start
        end

        desc 'Stops application server'
        task :stop do
          passenger.stop
        end

        desc 'Restarts application server'
        task :restart do
          passenger.restart
        end

        desc 'Deploys your project and runs the migrate rake task'
        task :full do
          stop
          update
          migrate
          restart
        end
      end
    end
  end
end
