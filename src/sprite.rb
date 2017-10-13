module Pokemon
	class Sprite
		include Utils::DynamicLoad

		attr_reader :width, :height

		def draw(frame, x, y, z)
			@source[frame].draw(x, y, z)
		end

		private_class_method :new

		private

		def load_data(data)
			fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::SPRITE_DIR, data['source'])
			Logger::log("Loading spritesheet for #{id} from #{Utils::relative_path(fn)}")
			@width = data['width']
			@height = data['height']
			@source = Gosu::Image.load_tiles(fn, @width, @height, {retro: true})
		end

		def get(path)
			a = @frames
			path.each do |id|
				
			end
			a
		end

		def self.resource_path
			[Utils::DATA_DIR, Utils::SPRITE_DIR]
		end
	end
end

