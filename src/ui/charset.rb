module Pokemon
	module UI
		class Charset
			attr_reader :char_width, :char_height

			def initialize(id)
				@id = id
				@size = Utils::char_size
				@char_width = @char_height = @size
				fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::CHARSET_DIR, "#{id}.png")
				@source = Gosu::Image::load_tiles(fn, @size, @size, { retro: true })
			end

			def draw(s, x, y, z)
				s.each_char do |c|
					@source[translate(c)].draw(x, y, z)
					x += @char_width
				end
			end

			def translate(c)
				c.ord
			end

			def self.[](id)
				@@charsets ||= {}
				@@charsets[id] = Charset.new(id) unless @@charsets[id]
				@@charsets[id]
			end
		end
	end
end

