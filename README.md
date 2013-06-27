# Capistrano Misc Recipes

This gem provides several capistrano tasks to help to access rails application environment and log files, fetch db dump from server and manage passenger process.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano_misc_recipies', group: :development

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano_misc_recipies

## Usage

### Console commands

Add to your Capfile:

```ruby
require 'capistrano_misc_recipies/console'
```

To open rails db console on first application server:

    $ cap console:db

To open rails console of first application server:

    $ cap console:rails

To open ssh session on first application server in project current directory:

    $ cap console:shell

To open tail --follow with application log file from server:

    $ cap console:tail_log

To get 1000 string from application log file from server:

    $ cap console:tail_log1000

### Fetch database dump from server

Add to your Capfile:

```ruby
require 'capistrano_misc_recipies/dbfetch'
```

To fetch db dump from server run:

    $ cap dbfetch

Gem also includes rake task to make dump of local database:

    $ rake db:sqldump

### Passenger standalone manage tasks

Add to your Capfile:

```ruby
require 'capistrano_misc_recipies/passenger'
```

Now you have `deploy:start`, `deploy:stop` and `deploy:restart` tasks which manage passenger process.
Passenger starts on _127.0.0.1:3000_ by default. Add next directives to your config/deploy.rb file to
override default:

```ruby
set :passenger_address, '127.0.0.1'
set :passenger_port, 3000
```

Also you may bind passenger to Unix domain socket instead of TCP socket:

```ruby
set :passenger_use_socket, true
```

Socket file default location (`#{Rails.root}/tmp/pids/#{Rails.env}.sock` by default) can be changed:

```ruby
set :passenger_socket_file, '/path/to/file.sock'
```

To customise deploy task override it in `config/deploy.rb` file:

```ruby
namespace :deploy do
  task :start do

    # some logic...

    passenger.start

    # some other logic...

  end
end
```

`passenger.start`, `passenger.stop` and `passenger.restart` tasks can be used.

### Generate sample nginx config for application

Task `cap passenger:nginx_config` prints sample nginx config and saves it in file application tmp dir

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
