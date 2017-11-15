module Pokemon
	module UI
		class Charset
			include Utils::DynamicLoad

			def draw(s, x, y, z)
				s.each do |ch, ci|
					i, pc, sc = translate(ch), *@colors[ci]
					@source[i].draw(x, y, z, color: pc)
					@source[i + @size].draw(x, y, z, color: sc)
					x += @char_widths[i]
				end
				x
			end

			def draw_plain(s, x, y, z)
				draw(s.chars.map { |c| [c, 0] }, x, y, z)
			end

			def char_height
				@tilesize
			end

			private_class_method :new

			private

			def translate(c)
				c.ord - 32
			end

			def load_data(data)
				fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::CHARSET_DIR, data['source'])
				Utils::Logger::log("Loading charset '#{id}' from #{Utils::relative_path(fn)}.")
				@tilesize, @size = data['tilesize'], data['size']
				@source, _, _ = *Utils::load_tiles(fn, @tilesize)
				@source.each { |img| img.scale = 1.0 }
				@char_widths = data['widths']
				
				@colors = data['colors'].map do |c|
					p = Gosu::Color.argb(0xff, *c['primary'])
					s = Gosu::Color.argb(0xff, *c['secondary'])
					[p, s]
				end
			end

			def self.resource_path
				[Utils::DATA_DIR, Utils::CHARSET_DIR]
			end
		end
	end
end

