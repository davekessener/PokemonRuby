module Pokemon
module Overworld
	class Tileset
		include Utils::DynamicLoad

		attr_reader :size, :tile_size

		def [](id)
			@tiles[id]
		end

		def animation?(name)
			not @animators[name].empty?
		end

		def animations(name)
			@animators[name]
		end

		private_class_method :new

		private

		def load_data(data)
			@tile_size = data['size']
			fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::TILESET_DIR, data['source'])
			@source, @cols, _ = *Utils::load_tiles(fn, @tile_size)
			@tiles = {}
			@animators = {}

			data['tiles'].each { |tile| load_tile [], tile }

			@size = @tiles.size
			@tile_size *= Utils::SCREEN_SCALE

			Utils::Logger::log("loaded tileset #{id} with #{@size} tiles!")
		end

		def load_tile(id, tile)
			id << tile['id']
			name = id.join ':'

			@animators[name] = tile['animation'] ? tile['animation'].split(/,/) : []

			if tile['group']
				tile['group'].each { |t| load_tile id.dup, t }
			elsif tile['frames']
				frames = tile['frames'].map { |f| get_raw(*f['at']) }
				@tiles[name] = Tile::Animation.new(frames, tile['period'])
			else
				@tiles[name] = Tile::Static.new(get_raw(*tile['at']))
			end
		end

		def get_raw(x, y)
			@source[x + y * @cols]
		end

		def self.resource_path
			[Utils::DATA_DIR, Utils::TILESET_DIR]
		end
	end
end

end
