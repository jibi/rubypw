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
	def load_db
		if File.exist?(@config[:db_file])
			get_db_password
			read_db
		else
			puts 'No db found: using a new one.'
			get_db_password
		end
	end

	def get_db_password
		print 'Key: '

		STDIN.noecho { @db_pw = STDIN.readline.chomp }
		print "\r"
	end

  def write_db 
		db = ''

		@pw.each { |k,v| db += "#{k} #{v}\n"  }
		return if db.empty?
		crypted = encrypt_data db, @db_pw

		#TODO: remove me: just backup db
		FileUtils.copy(@config[:db_file], @config[:db_file] + 
			Time.now.to_s.split(" ")[0..1].join("_")) if File.exist? @config[:db_file]

		File.open(@config[:db_file], 'w') { |f| f.write crypted } 
  end

  def read_db
		crypted = ''

  	File.open(@config[:db_file], 'r').each_line { |l| crypted += l }
		return if crypted.empty?
		db = decrypt_data crypted, @db_pw
		db.each_line { |l| l =~ /(.+) (.+)/; @pw[$1] = $2 }
	end
end
end

