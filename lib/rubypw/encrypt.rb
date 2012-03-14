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

module Encrypt
def encrypt_data data, key; do_crypt :encrypt, data, key; end
def decrypt_data data, key; do_crypt :decrypt, data, key; end

def do_crypt what, data, key
	c = OpenSSL::Cipher::Cipher.new('aes-256-cbc')
	c.send what
	c.pkcs5_keyivgen key

	begin
		c.update(data) + c.final
	rescue Exception => e
		abort "Fatal tragedy while #{what.to_s}ing: #{e}"
	end
end
end
