module CapistranoMiscRecipes
  module DbDump
    def DbDump.command options
      dump_file, dump_command = options['dump_file'], []

      case options["adapter"]
      when /^mysql/
        args = {
          'host'      => '--host',
          'port'      => '--port',
          'socket'    => '--socket',
          'username'  => '--user',
          'encoding'  => '--default-character-set',
          'sslca'     => '--ssl-ca',
          'sslcert'   => '--ssl-cert',
          'sslcapath' => '--ssl-capath',
          'sslcipher' => '--ssh-cipher',
          'sslkey'    => '--ssl-key'
        }.map { |opt, arg| "#{arg}=#{options[opt]}" if options[opt] }.compact

        if options['password'] && !options['password'].to_s.empty?
          args << "--password=#{options['password']}"
        end

        args << options['database']
        dump_command << 'mysqldump' << args

      when /^postgres/
        args = {
          'host'      => '--host',
          'port'      => '--port',
          'username'  => '--user',
          'encoding'  => '--encoding',
        }.map { |opt, arg| "#{arg}=#{options[opt]}" if options[opt] }.compact

        args << options['database']
        dump_command << "pg_dump --clean --no-owner" << args
        # TODO password

      else
        # TODO handle error capistrano and rake way
        abort "Unknown command-line client for #{options['database']}"
      end

      case options['pack']
      when 'bzip2' ; dump_command << '| bzip2 -c'
      when 'gzip'  ; dump_command << '| gzip'
      end

      dump_command << '>'

      dump_command << dump_file
      dump_command = dump_command.join ' '

      return dump_command
    end
  end
end
