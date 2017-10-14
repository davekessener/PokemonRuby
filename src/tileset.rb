require 'JSON'

module Pokemon
	class Tileset
		include Utils::DynamicLoad

		attr_reader :size

		def [](id)
			@tiles[id]
		end

		private_class_method :new

		private

		def load_data(data)
			@tilesize = data['size']
			raise ArgumentError, "Invalid tilesize #{@tilesize}! Expected #{Utils::TILE_SIZE}!" if @tilesize != Utils::TILE_SIZE
			src = data['source']
			fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::TILESET_DIR, src['path'])
			@source = Utils::load_tiles(fn, @tilesize)
			@cols = src['width'] / @tilesize
			@tiles = {}
			
			data['tiles'].each { |tile| load_tile [], tile }

			@size = @tiles.size

			Logger::log("loaded tileset #{id} with #{@size} tiles.")
		end

		def load_tile(id, tile)
			id << tile['id']
			name = id.join ':'
			if tile['group']
				tile['group'].each { |t| load_tile(id.dup, t) }
			elsif tile['frames']
				frames = tile['frames'].map { |f| get_raw(*f['at']) }
				@tiles[name] = Tile::Animation.new(name, @size, tile['period'], frames)
			else
				@tiles[name] = Tile::Base.new(name, @size, get_raw(*tile['at']))
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

