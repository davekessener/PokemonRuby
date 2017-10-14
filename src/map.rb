module Pokemon
	class Map
		include Utils::DynamicLoad

		attr_reader :map, :width, :height, :player_sprite

		def enter_map(px, py)
			@player_sprite.px = px
			@player_sprite.py = py
			$world.map = self
			$world.player.sprite = @player_sprite
		end

		def can_move?(o, d)
			return true unless o.corporal?
			
			dir = Utils::Directions[d]
			tx, ty = o.px + dir.dx, o.py + dir.dy
			m, n = get_meta(o.px, o.py), @neighbors[d]

			if n and out_of_bounds?(tx, ty)
				px, py = tx + n.dx, ty + n.dy
				n.map.map.can_move?(px, py, d, m)
			else
				@map.can_move?(tx, ty, d, m)
			end
		end

		def enter_tile(o)
			r = out_of_bounds?(o.px, o.py)
			n = @neighbors[r]

			if r and n
				n.map.enter_map(o.px + n.dx, o.py + n.dy)
			end
		end

		def exit_tile(o)
		end

		def on_move(o, dir)
			d = Utils::Directions[dir]
			tx, ty = o.px + d.dx, o.py + d.dy
			get_meta(tx, ty).on_move(o, dir)
		end

		def out_of_bounds?(tx, ty)
			return :left if tx < 0
			return :up if ty < 0
			return :right if tx >= @width
			return :down if ty >= @height
			false
		end

		def get_meta(x, y)
			d = out_of_bounds?(x, y)
			if d
				n = @neighbors[d]
				if n
					tx, ty = x + n.dx, y + n.dy
					n.map.get_meta(tx, ty)
				end
			else
				@map.meta[y][x]
			end
		end

		def update(delta)
			@player_sprite.update(delta)
		end

		def draw(x, y)
			@map.draw(x, y)

			if @border
				l = Utils::TILE_SIZE
				tx, ty = x, y
				w, h = @width * l, @height * l
				x2, y2 = x + w, y + h
				tw, th = @border.width * l, @border.height * l
				sw, sh = Utils::screen_width, Utils::screen_height

				while tx > 0 do
					tx -= tw
				end
				while ty > 0 do
					ty -= th
				end

				b = tx
				while ty < sh do
					tx = b
					while tx < sw
						if tx == x and (ty >= y and ty < y2)
							tx = x2
							next
						end
					
						@border.draw(tx, ty)

						tx += tw
					end

					ty += th
				end
			end

			@neighbors.each do |d, n|
				n.map.map.draw(x - n.dx * Utils::TILE_SIZE, y - n.dy * Utils::TILE_SIZE)
			end

			Gosu::translate(x, y) do
				@player_sprite.draw
			end
		end

		private_class_method :new

		private

		def load_data(data)
			@name = data['name']
			@map = Tilemap[data['map']]
			@border = Tilemap[data['border']]
			@width = @map.width
			@height = @map.height

			@neighbors = {}
			data['neighbors'].each do |d, n|
				dir = d.to_sym
				@neighbors[dir] = Utils::Neighbor.new(self, n['id'], dir, n['offset'])
			end

			@player_sprite = OverworldSprite::Container.new
			@player_sprite.sprite = Sprite['gold']
			@player_sprite.corporal = true
		end

		def self.resource_path
			[Utils::DATA_DIR, Utils::MAP_DIR]
		end
	end
end

