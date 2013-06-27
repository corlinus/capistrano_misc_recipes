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


        desc '[internal] Start passenger'
        task :start, roles: :app do

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
          run command.join ' '

        end

        desc '[internal] Stop passenger'
        task :stop, roles: :app do
          run "cd #{current_path} && #{bundlify 'passenger'} stop --pid-file #{passenger_pid_file} ; true"
        end

        desc '[internal] Restart passenger'
        task :restart, roles: :app, except: { no_release: true } do
          run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
        end

        desc 'generates nginx virtual host template file'
        task :nginx_config do

          proxy_pass = if passenger_use_socket
                         "http://unix:#{passenger_socket_file}"
                       else
                         "http://#{passenger_address}:#{passenger_port}"
                       end

          conf_file = <<CONF

# nginx virtual host file for
#    application: #{application}
#{exists?(:stages) ? "#    stage: #{stage}\n" : nil}
server {
    listen 80;
    server_name #{application}
    root #{File.join current_path, 'public'};
    client_max_body_size 15M;

    location / {
        try_files /system/maintence.html
          $uri $uri/index.html $uri.html
          @passenger;
    }

    location @passenger {
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $remote_addr;

        proxy_pass #{proxy_pass};
    }

    error_page 500 502 503 504 /500.html;
    error_page 404 403 /404.html;
}

CONF

          puts conf_file
          # save file in application tmp dir
          put conf_file, Pathname.new(current_path).join('tmp', [application, exists?(:stages) ? stage : nil].compact.join(?_)).to_s
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
