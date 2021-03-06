module Pokemon
module Overworld
	module Sprite
		class Base
			include Utils::DynamicLoad

			attr_reader :width, :height, :frames

			def draw(path, idx, p, x, y, z)
				f = @frames
				path.each { |e| f = f[e.to_s] }
				@source[f.frame(idx, p)].draw(x, y, z)
			end

			def centered(&block)
				l = $world.tile_size
				Gosu::translate((l - @width) / 2, @offset - (@height - l), &block) if block_given?
			end

			private_class_method :new

			private

			def load_data(data)
				fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::SPRITE_DIR, data['source'])
				Utils::Logger::log("Loading sprite sheet #{id} from '#{Utils::relative_path(fn)}'.")
				@width, @height = data['width'], data['height']
				@source, cols, _ = *Utils::load_tiles(fn, @width, @height)
				@offset = data['offset']

				if data['sprite']
					@frames = Frame.new(data['sprite'], cols)
				else
					s = Sprite[data['parent']]
					@frames = s.frames
				end

				@width *= Utils::SCREEN_SCALE
				@height *= Utils::SCREEN_SCALE
			end

			def self.resource_path
				[Utils::DATA_DIR, Utils::SPRITE_DIR]
			end
		end

		def self.[](id)
			Base[id]
		end
	end
end

end
