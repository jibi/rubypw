#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#

require 'yaml'
require 'ruport'
require 'io/console'

module RubyPw

class Manager
	include RandomChar
	include Dump
	include Config

	def initialize(dir)
		@pw        = Hash.new
		@modified  = false
		@db_loaded = false

		do_config(dir)

		Dir.mkdir(dir) if not Dir.exist?(dir)
	end

	def do_config(dir)
		conf_file = dir + CONF_FILE

		@config = File.exist?(conf_file) ?
			open(CONF_FILE) { |file| YAML.load(file) } : {}

		@config[:db_file] ||= dir + DB_FILE
		@config[:qr_file] ||= QR_FILE
		@config[:pw_len]  ||= PW_LENGTH

		@config[:db_file] = File.expand_path @config[:db_file]
		@config[:qr_file] = File.expand_path @config[:qr_file]
	end

	def do_action(args)
		action = args.delete_at(0)

		if %w(get upd del list get_users_like).include?(action) and not @db_loaded
			raise 'No db found, cannot do action ' + action if not db_exists?
		end

		if %w(add file get upd del list get_users_like).include?(action) and not @db_loaded
			load_db
			@db_loaded = true
		end

		if %w(add file get upd del list gen dump).include?(action)
			send(action + '_password', args)
		else
			send(action , args)
		end

		write_db if @modified
	end

	def add_password(args)
		username = args[0]

		set_password(username, false)
	end

	def upd_password(args)
		username = args[0]

		set_password(username, true)
	end

	def set_password(username, update)
		raise ArgumentError, 'Empty username.' if username.empty?

		print 'Password (blank for random password): '

		password = STDIN.noecho { STDIN.readline.chomp }
		if password.empty?
			password = Manager.random_chars(@config[:pw_len])
		else
			print "\nRetype password: "
			_password = STDIN.noecho { STDIN.readline.chomp }

			raise 'Passwords do not match.' if password != _password
		end
		puts ''

		_set_password(username, password, update)
	end

	def get_password(args)
		username = args[0]

		if @pw[username].nil?
			puts "No pw found."
		else
			puts @pw[username]
		end
	end

	def del_password(args)
		username = args[0]

		if @pw[username].nil?
			puts "#{username} does not exist.\nNot deleting."
		else
			@pw.delete(username)
		end

		@modified = true
	end

	def file_password(args)
		filename = args[0]

		File.open(File.expand_path(filename), "r").each_line { |l|
			l =~ /(.+) (.+)/
			_set_password($1, $2)
		}
	end

	def list_password(stub)
		table              = Ruport::Data::Table.new
		table.column_names = %w(user password)

		@pw.each { |n,v| table << [n,v] }
		puts table.to_text
	end

	def _set_password(username, password, overwrite)
		if not @pw[username].nil? and not overwrite
			raise "#{username} already exists.\nNot updating: please delete first."
		elsif @pw[username].nil? and overwrite
			raise "#{username} does not exist.\nNot updating: please add first."
		end

		@pw[username] = password
		@modified = true
	end

	def gen_password(args)
		pw_len = args[0].nil? ? @config[:pw_len] : args[0]

		str = Manager.random_chars(pw_len)
		puts str
	end

	def dump_password(args)
		file = args[0].nil? ? @config[:qr_file] : args[0]

		db = ""
		File.open(@config[:db_file], 'r').each_line { |l| db += l }
		Manager.dump_to_qrcode(db, 4, file.nil? ? @config[:qr_file] : file)
	end

	def get_users_like(args)
		what = args[0]

		puts @pw.select { |k, v| k.match(what) }.keys
	end
end
end

