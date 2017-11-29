module Pokemon
module Overworld
	class Tilemap
		include Utils::DynamicLoad

		attr_reader :width, :height

		def tile_size
			@tileset.tile_size
		end

		def meta_at(px, py)
			@meta[py][px].to_sym
		end

		def create
			Array.new(@width) do |x|
				Array.new(@height) do |y|
					e = TileEntity.new(x, y, Meta[@meta[y][x].to_sym], @animators[y][x])

					Utils::layers.each do |z_id|
						z = Utils::get_z(z_id)
					
						@maps[z_id].each do |l|
							e.add(z, l[x][y]) if l[x][y]
						end
					end
					
					e
				end
			end
		end

		def draw(px, py, x, y)
			Utils::layers.each do |z_id|
				z = Utils::get_z(z_id)
				@maps[z_id].each do |layer|
					layer[px][py].draw(x, y, z) if layer[px][py]
				end
			end
		end

		private_class_method :new

		private

		def load_data(data)
			@width, @height = data['width'], data['height']
			@tileset = Tileset[data['tileset']]
			@maps = {}
			@meta = []

			@animators = Array.new(@height) { |col| Array.new(@width) { |row| [] } }

			map = data['map']
			Utils::layers.each do |z_id|
				@maps[z_id] = []

				@maps[z_id] = map[z_id.to_s].map do |layer|
					Array.new(@width) do |x|
						Array.new(@height) do |y|
							if (l = layer[y][x])
								@tileset[l].tap do |e|
									@animators[y][x] = @tileset.animations(l).map do |a|
										id, args = *a.split(/:/)
										Animator[id.to_sym].new(args ? args.split(/,/) : [])
									end if @tileset.animation? l
								end
							end
						end
					end
				end if map[z_id.to_s]
			end

			@meta = data['meta']
		end

		def self.resource_path
			[Utils::DATA_DIR, Utils::TILEMAP_DIR]
		end
	end
end

end
