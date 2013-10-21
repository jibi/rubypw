#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#

require 'io/console'
require 'fileutils'

module RubyPw
class Manager
	def db_exists?
		File.exist?(@config[:db_file])
	end

	def load_db
		if db_exists?
			get_db_password(false)
			salt, iter, iv, crypted = read_db
			iter = iter.to_i

			@crypter = Crypter.new(@db_pw, salt, iter, iv)

			@crypter.decrypt_data(crypted).each_line { |l|
				l       =~ /(.+) (.+)/
				@pw[$1] = $2
			} if not crypted.nil?
		else
			puts 'No db found: using a new one.'
			get_db_password(true)

			@crypter = Crypter.new(@db_pw)
		end
	end

	def get_db_password(first_time)
		print('Key: ')
		@db_pw = STDIN.noecho { STDIN.readline.chomp }
		print("\r     \r")

		if first_time
			print('Retype key: ')
			_db_pw = STDIN.noecho { STDIN.readline.chomp }
			print("\r            \r")

			raise 'Keys do not match.' if @db_pw != _db_pw
		end
	end

	def write_db
		db = ''
		@pw.each { |k,v| db += "#{k} #{v}\n"  }

		if db.empty?
			crypted = ''
		else
			crypted = @crypter.encrypt_data(db)
			salt    = @crypter.salt
			iter    = "%08d" % @crypter.iter
			iv      = @crypter.iv

			#
			# DB format:
			# =========================================================
			# salt:       string, 8 bytes
			# iter:       string, 8 bytes (will be converted to integer)
			# iv:         string, 16 bytes
			# cyphertext: string
			#

			crypted = salt + iter + iv + crypted
		end

		#TODO: remove me: just backup db
		FileUtils.copy(@config[:db_file], @config[:db_file] +
			Time.now.to_s.split(" ")[0..1].join("_")) if File.exist?(@config[:db_file])

		File.open(@config[:db_file], 'w') { |f| f.write(crypted) }
	end

	def read_db
		crypted = ''

		File.open(@config[:db_file], 'r').each_line { |l| crypted += l }
		return if crypted.empty? || crypted.size < 28

		crypted.unpack("A8A8A16A*")
	end
end
end

