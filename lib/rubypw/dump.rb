#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#                    Version 2, December 2004
#
#            DO WHAT THE FUCK YOU WANT TO PUBLIC LICENSE
#   TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION
#
#  0. You just DO WHAT THE FUCK YOU WANT TO. 
#

require 'rqrcode'
require 'chunky_png'
require 'base64'

module Dump
	def self.included base
		base.extend Mod
	end

	module Mod
		def dump_to_qrcode(data, zoom, file)
			qr_size = 1
			data    = Base64.encode64(data)

			begin
				qr = RQRCode::QRCode.new(data, :size => qr_size)
			rescue
				raise 'qrcode: data too big' if qr_size == 40

				qr_size += 1
				retry
			end

			size = qr.module_count
			png = ChunkyPNG::Image.new(size * zoom, size * zoom)
		
			size.times { |x| size.times { |y|
				zoom.times { |i| zoom.times { |j|
					png[x * zoom + i, y * zoom + j] = ChunkyPNG.Color(qr.dark?(x,y) ? 'black' : 'white')
				}}
			}}
	
			png.save file
		end
	end
end

