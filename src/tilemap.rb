module Pokemon
	class Tilemap
		include Utils::DynamicLoad

		attr_reader :width, :height

		def tile_size
			@tileset.tile_size
		end

		def create
			Array.new(@width) do |x|
				Array.new(@height) do |y|
					e = TileEntity[@meta[y][x].to_sym]

					[:background, :bottom, :top].each do |z_id|
						z = Utils::get_z(z_id)
					
						@maps[z_id].each do |l|
							e.add(z, l[x][y]) if l[x][y]
						end
					end
					
					e
				end
			end
		end

		def draw(px, py, x, y, z_id)
			z = Utils::get_z(z_id)
			@maps[z_id].each do |layer|
				layer[px][py].draw(x, y, z) if layer[px][py]
			end
		end

		private_class_method :new

		private

		def load_data(data)
			@width, @height = data['width'], data['height']
			@tileset = Tileset[data['tileset']]
			@maps = {background: [], bottom: [], top: []}
			@meta = []

			data['map'].each do |map|
				order, layer = map['order'].to_sym, map['layer']

				@maps[order] << Array.new(@width) do |x|
					Array.new(@height) do |y|
						layer[y][x] ? @tileset[layer[y][x]] : nil
					end
				end
			end

			@meta = data['meta']
		end

		def self.resource_path
			[Utils::DATA_DIR, Utils::TILEMAP_DIR]
		end
	end
end

