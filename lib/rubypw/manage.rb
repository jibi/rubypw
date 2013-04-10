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
	
	module Config
	RUBYPW_DIR = File.expand_path '~/.rubypw'
	CONF_FILE	 = RUBYPW_DIR + '/conf'

	DB_FILE 	 = RUBYPW_DIR + '/db'
	QR_FILE 	 = '~/qrpw.png'
	PW_LENGTH	 = 16
	end

	class << self
		def start(args)
			manager = Manager.new
			manager.do_action(args)

			manager
		end
	end

	def initialize
		@pw	  = Hash.new
		@modified = false
		@db_loaded = false

		do_config

		Dir.mkdir Config::RUBYPW_DIR if not Dir.exist?(Config::RUBYPW_DIR)
	end

	def do_config
		@config = {}

		@config = open(Config::CONF_FILE) { |file|
			YAML.load(file) } if File.exist?(Config::CONF_FILE)

		@config[:db_file] ||= Config::DB_FILE
		@config[:db_file] = File.expand_path @config[:db_file]
		@config[:qr_file] ||= Config::QR_FILE
		@config[:qr_file] = File.expand_path @config[:qr_file]
		@config[:pw_len] ||= Config::PW_LENGTH
	end

	def do_action(args)
		action = args.delete_at(0)

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
			password = Manager.random_chars @config[:pw_len]
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
			_set_password $1, $2
		}
	end

	def list_password(stub)
		table = Ruport::Data::Table.new
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

