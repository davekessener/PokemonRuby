require 'JSON'

module Pokemon
	class Tilemap
		include Utils::DynamicLoad

		attr_reader :width, :height, :meta

		def draw(x, y)
			@maps.each do |z_id, maps|
				z = Utils::get_z(z_id)
				maps.each do |map|
					draw_map(map, x, y, z)
				end
			end
		end

		def can_move?(tx, ty, d, m)
			if tx >= 0 and tx < @width and ty >= 0 and ty < @height
				@meta[ty][tx].can_enter_from(d, m)
			else
				false
			end
		end

		private_class_method :new

		private

		TAG_WIDTH = 'width'
		TAG_HEIGHT = 'height'
		TAG_TILESET = 'tileset'
		TAG_MAP = 'map'
		TAG_ORDER = 'order'
		TAG_LAYER = 'layer'
		TAG_META = 'meta'

		def ensureArgument(o, id, s)
			raise ArgumentError, "Expected tag #{id} to be #{s}!" if o[id].nil? or (block_given? and not yield(o[id]))
		end

		def load_data(data)
			ensureArgument(data, TAG_WIDTH, 'a positive number') { |e| e.is_a? Integer and e > 0 }
			ensureArgument(data, TAG_HEIGHT, 'a positive number') { |e| e.is_a? Integer and e > 0}
			ensureArgument(data, TAG_TILESET, 'a tileset id') { |e| e.is_a? String }
			ensureArgument(data, TAG_MAP, 'a list of layers') { |e| e.respond_to? :[] }
			ensureArgument(data, TAG_META, 'an array of meta ids') { |e| e.respond_to? :[] }

			@width = data[TAG_WIDTH]
			@height = data[TAG_HEIGHT]
			@tileset = Tileset[data[TAG_TILESET]]
			@maps = {background: [], bottom: [], top: []}
			@meta = []

			data[TAG_MAP].each do |map|
				ensureArgument(map, TAG_ORDER, 'a valid ordering id') { |e| e.is_a? String }
				ensureArgument(map, TAG_LAYER, 'an array of tile ids') { |e| e.respond_to? :[] }

				order, layer = map[TAG_ORDER].to_sym, map[TAG_LAYER]
				
				raise ArgumentError, "Invalid order '#{order}'!" unless @maps[order]
				
				@maps[order] << Array.new(@height) do |y|
					Array.new(@width) do |x|
						layer[y][x] ? @tileset[layer[y][x]] : nil
					end
				end
			end

			meta = data[TAG_META]

			raise ArgumentError, "Expecting meta map to have a height of #{@height}, not #{meta.size}!" if meta.size != @height
			meta.each_with_index do |layer, y|
				ensureArgument(meta, y, 'an array of meta ids') { |e| e.respond_to? :[] }
				raise ArgumentError, "Expecting meta map to have a width of #{@width}, but row #{y + 1} has a width of #{layer.size}!" if layer.size != @width
				layer.each_with_index do |id, x|
					raise ArgumentError, "Expecting a meta id, not nil!" if not id.is_a? String
					raise ArgumentError, "'#{id}' is not a valid meta id!" if not Tile::MetaData[id.to_sym]
				end
			end

			@meta = Array.new(@height) do |y|
				Array.new(@width) do |x|
					Tile::MetaData[meta[y][x].to_sym]
				end
			end

			raise ArgumentError, "Invalid metadata!" if @meta.any? { |l| l.any? { |t| t.nil? } }

			Logger::log("loaded tilemap #{id} (#{@width} x #{@height} x #{@maps[:top].size + @maps[:bottom].size}) using tileset #{data['tileset']}")
		end

		def draw_map(map, x, y, z)
			map.each_with_index do |row, py|
				row.each_with_index do |tile, px|
					tile.draw(x + px * Utils::TILE_SIZE, y + py * Utils::TILE_SIZE, z) if tile
				end
			end
		end

		def self.resource_path
			[Utils::DATA_DIR, Utils::TILEMAP_DIR]
		end
	end
end

