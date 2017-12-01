module Pokemon
module Overworld
	module Map
		def self.[](id)
			Container[id]
		end

		class Container
			include Utils::DynamicLoad

			attr_reader :tile_size, :tiles

			def update(delta)
				@tiles.each do |row|
					row.each do |tile|
						tile.update(delta)
					end
				end
			end

			def tilemap
				@map
			end

			def draw(viewport)
				l = tile_size
				px0, py0 = *viewport.lower_bound(l)
				px1, py1 = *viewport.upper_bound(l)

				(px0...px1).each do |x|
					(py0...py1).each do |y|
						map, px, py = *from_coords(x, y)
						if map.is_a? self.class
							map.tiles[px][py].draw(x * l, y * l)
						else
							map.draw(px, py, x * l, y * l)
						end
					end
				end
			end

			def entities
				@entities.map do |id, v|
					t, pos = *v
					[id, t.instantiate(id, *pos)]
				end.to_h
			end

			def renderer_at(px, py)
				map, x, y = *from_coords(px, py)

				if map.is_a? self.class
					map.tiles[x][y].renderer
				else
					nil
				end
			end

			def meta_at(px, py)
				map, x, y = *from_coords(px, py)

				if map.is_a? self.class
					map.tilemap.meta_at x, y
				else
					@map.meta_at x, y
				end
			end

			def player_interact(px, py)
				map, x, y = *from_coords(px, py)
				map.tiles[x][y].interact if map.is_a? self.class
			end

			def player_trigger(px, py)
				@tiles[px][py].trigger
			end

			def player_enter(player)
				entity_enter(player)
				player_trigger(player.px, player.py)
			end

			def player_leave(player)
				entity_leave(player)
			end

			def entity_enter(e)
				@tiles[e.px][e.py].enter(e)
			end

			def entity_leave(e)
				@tiles[e.px][e.py].exit(e)
			end

			def can_move_to(entity, px, py)
				map, x, y = *from_coords(px, py)
				map.tiles[x][y].can_enter(entity, @tiles[entity.px][entity.py]) if map.is_a? self.class
			end

			def enter
				$savefile.save
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

			def from_coords(px, py)
				if out_of_bounds? px, py
					@neighbors.each do |d, n|
						ppx, ppy = px + n.dx, py + n.dy
						return [n.map, ppx, ppy] if not n.map.out_of_bounds? ppx, ppy
					end
					[@border, *oob_coords(px, py)]
				else
					[self, px, py]
				end
			end

			private_class_method :new

			private

			def load_data(data)
				@name = data['name']
				@map = Tilemap[data['map']]
				@border = Tilemap[data['border']] if data['border']
				@tiles = @map.create

				@neighbors = {}
				data['neighbors'].each do |d, n|
					@neighbors[d.to_sym] = Neighbor.new(self, n['id'], d, n['offset'])
				end if data['neighbors']

				@entities = {}
				data['entities'].each do |e|
					@entities[e['id']] = [Template[e['type']].new(e['argument']), e['at']]
				end if data['entities']
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
end

end
