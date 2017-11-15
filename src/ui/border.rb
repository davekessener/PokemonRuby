module Pokemon
	module UI
		class Border
			include Utils::DynamicLoad

			attr_reader :offset

			def draw(x, y, w, h, z)
				sx = (w - 2 * @tilesize) / @tilesize.to_f
				sy = (h - 2 * @tilesize) / @tilesize.to_f

				@source[0].draw(x, y, 10000)
				@source[2].draw(x + w - @tilesize, y, z)
				@source[6].draw(x, y + h - @tilesize, z)
				@source[8].draw(x + w - @tilesize, y + h - @tilesize, z)
				
				@source[1].draw(x + @tilesize, y, z, sx: sx)
				@source[3].draw(x, y + @tilesize, z, sy: sy)
				@source[5].draw(x + w - @tilesize, y + @tilesize, z, sy: sy)
				@source[7].draw(x + @tilesize, y + h - @tilesize, z, sx: sx)

				@source[4].draw(x + @tilesize, y + @tilesize, z, sx: sx, sy: sy)
			end

			private_class_method :new

			private

			def load_data(data)
				fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::BORDER_DIR, data['source'])
				Utils::Logger::log("Loading windowframe '#{id}' from #{Utils::relative_path(fn)}.")
				@tilesize = data['tilesize']
				@source, _, _ = *Utils::load_tiles(fn, @tilesize)
				@source.each { |img| img.scale = 1.0 }
				@offset = {x: data['offsets'][0], y: data['offsets'][1]}
			end

			def self.resource_path
				[Utils::DATA_DIR, Utils::BORDER_DIR]
			end
		end
	end
end

