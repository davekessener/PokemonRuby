module Pokemon
	module UI
		class Charset
			attr_reader :char_width, :char_height

			def initialize(id)
				@id = id
				@char_width = @char_height = @size = Utils::CHAR_SIZE
				fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::CHARSET_DIR, "#{id}.png")
				@source = Utils::load_tiles(fn, @size)
				Utils::Logger::log("loaded #{@source.size} tiles from charset '#{Utils::relative_path(fn)}'")
			end

			def draw(s, x, y, z)
				s.each_char do |c|
					@source[translate(c)].draw(x, y, z)
					x += @size
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

