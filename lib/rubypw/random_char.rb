#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO.
#

module RandomChar
	def self.included base
		base.extend Mod
	end

	module Mod
		def random_chars(len)
			sym = ('a'..'z').to_a + ('A'..'Z').to_a + ('0'..'9').to_a + %w(! ? @ # [ ] ( ) _ -)
			str = ''

			len.to_i.times { str += sym[rand(sym.size)] }
			str.split(//).shuffle.join #useless
		end
	end
end

