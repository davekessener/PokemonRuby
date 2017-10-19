module Pokemon
	class Map
		include Utils::DynamicLoad

		attr_reader :tile_size, :tiles

		def update(delta)
			@tiles.each do |row|
				row.each do |tile|
					tile.update(delta)
				end
			end
		end

		def draw(viewport)
			l = tile_size
			px0, py0 = *viewport.lower_bound(l)
			px1, py1 = *viewport.upper_bound(l)

			(px0...px1).each do |x|
				(py0...py1).each do |y|
					map, px, py = *from_coords(x, y)
					if map.is_a? Map
						map.tiles[px][py].draw(x * l, y * l)
					else
						map.draw(px, py, x * l, y * l, :background)
					end
				end
			end
		end

		def entities
			ObjectPool.new
		end

		def renderer_at(px, py)
			map, x, y = *from_coords(px, py)
			if map.is_a? Map
				map.tiles[x][y].renderer
			else
				nil
			end
		end

		def player_enter(player)
			t = @tiles[player.px][player.py]
			t.enter(player.model.facing)
			t.trigger(player)
		end

		def player_leave(player)
			@tiles[player.px][player.py].exit(player.model.facing)
		end

		def can_move_to(entity, px, py)
			map, x, y = *from_coords(px, py)
			map.tiles[x][y].can_enter(entity) if map.is_a? Map
		end

		def enter
		end

		def exit
		end

		def width
			@map.width
		end

		def height
			@map.height
		end

		def tile_size
			@map.tile_size
		end

		def out_of_bounds?(px, py)
			return :left if px < 0
			return :right if px >= width
			return :up if py < 0
			return :down if py >= height
			false
		end

		private_class_method :new

		private

		def from_coords(px, py)
			d = out_of_bounds? px, py
			if d
				n = @neighbors[d]
				if n
					ppx, ppy = px + n.dx, py + n.dy
					if n.map.out_of_bounds? ppx, ppy
						[@border, *oob_coords(px, py)]
					else
						[n.map, ppx, ppy]
					end
				else
					[@border, *oob_coords(px, py)]
				end
			else
				[self, px, py]
			end
		end

		def load_data(data)
			@name = data['name']
			@map = Tilemap[data['map']]
			@border = Tilemap[data['border']] if data['border']
			@tiles = @map.create

			@neighbors = {}
			data['neighbors'].each do |d, n|
				@neighbors[d.to_sym] = Utils::Neighbor.new(self, n['id'], d, n['offset'])
			end
		end

		def self.resource_path
			[Utils::DATA_DIR, Utils::MAP_DIR]
		end

		def oob_coords(px, py)
			return [0, 0] unless @border
			[oob_coord(px, @border.width), oob_coord(py, @border.height)]
		end

		def oob_coord(v, l)
			(v < 0) ? (v % l) : ((v - width) % l)
		end
	end
end

