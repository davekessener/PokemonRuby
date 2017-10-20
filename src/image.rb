module Pokemon
	class Image
		def initialize(source)
			@source = source
		end

		def width
			@source.width
		end

		def height
			@source.height
		end

		def draw(x, y, z)
			@source.draw(x, y, z, Utils::SCREEN_SCALE, Utils::SCREEN_SCALE)
		end

		def subimage(x, y, w, h)
			Image::from_image(@source.subimage(x, y, w, h))
		end

		def tiles(w, h)
			r = []
			(height / h).times do |y|
				(width / w).times do |x|
					r << subimage(x * w, y * h, w, h)
				end
			end
			r
		end

		def self.from_image(src)
			new(src)
		end

		def self.from_file(fn, retro = true)
			src = Gosu::Image.new(fn, {retro: retro})
			Utils::Logger::log("Loading image '#{fn}'.")
			new(src)
		end

		private_class_method :new
	end
end

