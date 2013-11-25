module RubyPw
module CLI
  def self.included base
    base.extend Mod
  end

  module Mod
    include Config

    def start_cli(args, dir = RUBYPW_DIR)
      @@manager = Manager.new(dir)

      action = args.delete_at(0)

      args_check(action, args)

      if %w(add file get upd del list like).include?(action)
        db_password = read_db_password_from_stdin

        @@manager.load_db(db_password)
      end

      begin
        do_action(action, args)
        @@manager.write_db
      rescue Exception => e
        abort e.message
      end

    end

    def args_check(action, args)
      if %w(add get upd del).include?(action) and args[0].nil?
        abort 'No user specified.'
      end

      if action.eql? 'file' and args[0].nil?
        abort 'No file specified.'
      end

      if %w(get upd del list like).include?(action) and not @@manager.db_exists?
        abort 'No db found, cannot do ' + action
      end
    end

    def do_action(action, args)
      case action
      when 'add'
        username = args[0]
        password = read_password_from_stdin

        @@manager.add_password(username, password)
      when 'get'
        username = args[0]

        puts @@manager.get_password(username)
      when 'upd'
        username = args[0]
        password = read_password_from_stdin

        @@manager.upd_password(username, password)
      when 'del'
        username = args[0]
        @@manager.del_password(username)
      when 'list'
        table              = Ruport::Data::Table.new
        table.column_names = %w(user password)

        @@manager.pw.each do |n,v|
          table << [n,v]
        end

        puts table.to_text
      when 'like'
        what = args[0]

        puts @@manager.get_users_like(what)
      when 'gen'
        pw_len = args[0].nil? ? @@manager.config[:pw_len] : args[0]

        puts Manager.random_chars(pw_len)
      when 'dump'
        db   = ""
        file = args[0].nil? ? @@manager.config[:qr_file] : args[0]

        File.open(@@manager.config[:db_file], 'r').each_line do |l|
          db += l
        end

        Manager.dump_to_qrcode(db, 4, file)
      else
        abort 'Invalid action.'
      end

    end

    def read_password_from_stdin()
      print 'Password (blank for random password): '

      password = STDIN.noecho { STDIN.readline.chomp }
      if password.empty?
        password = Manager.random_chars(@@manager.config[:pw_len])
      else
        print "\nRetype password: "
        _password = STDIN.noecho { STDIN.readline.chomp }

        abort 'Passwords do not match.' if password != _password
      end
      puts ''

      password
    end

    def read_db_password_from_stdin
      print('Key: ')
      password = STDIN.noecho { STDIN.readline.chomp }
      print("\r     \r")

      if not @@manager.db_exists?
        print('Retype key: ')
        _password = STDIN.noecho { STDIN.readline.chomp }
        print("\r            \r")

        abort 'Keys do not match.' if password != _password
      end

      password
    end

  end
end
end

