# Capistrano Misc Recipies

This gem provides several capistrano tasks to help to access rails application environment and log files.

## Installation

Add this line to your application's Gemfile:

    gem 'capistrano_misc_recipies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install capistrano_misc_recipies

## Usage

Add to your Capfile:

    require 'capistrano_misc_recipies/console'

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
