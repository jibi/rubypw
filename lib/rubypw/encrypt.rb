#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#

require 'openssl'

module RubyPw
class Crypter
	MIN_ITER = 100000
	attr_reader :salt, :iter, :iv

	def initialize(pw, salt=nil, iter=nil, iv=nil)

		@salt	= salt.nil? ? OpenSSL::Random.random_bytes(8) : salt
		@iter	= iter.nil? ? (rand * MIN_ITER + MIN_ITER).to_i : iter
		@iv	= iv.nil? ? OpenSSL::Random.random_bytes(16) : iv

		print 'Unlocking...'
		@key	= OpenSSL::PKCS5::pbkdf2_hmac_sha1(pw,@salt,@iter,32)
		print "\r            \r"
	end

	def encrypt_data(data); do_crypt :encrypt, data; end
	def decrypt_data(data); do_crypt :decrypt, data; end

	def do_crypt(what, data)
		c = OpenSSL::Cipher::Cipher::AES.new(256, :CBC)
		c.send what

		c.key	= @key
		c.iv	= @iv

		begin
			c.update(data) + c.final
		rescue Exception => e
			fail "Fatal tragedy while #{what.to_s}ing: #{e}"
		end
	end
end
end
