module Pokemon
	class World
		attr_reader :player, :player_input

		def initialize
			@player_input = $input.create(:player)
		end

		def load(data)
			@map = Map[data['map']]
			@player = Player.new(@player_input, data)
			@camera = Camera.new(@player.model)
			@entities = @map.entities
			@entities.add(@player)
			@map.enter
		end

		def save
		end

		def update(delta)
			@map.update(delta)
			@entities.update(delta)
		end

		def draw
			@camera.offset do |viewport|
				@map.draw(viewport)
				@entities.each { |e| e.draw if viewport.overlap? e.model }
			end
		end

		def renderer_at(px, py)
			@map.renderer_at(px, py)
		end

		def tile_size
			@map.tile_size
		end

		def can_move_to(entity, px, py)
			return false if @entities.any? { |e| e.corporal and e.px == px and e.py == py }
			@map.can_move_to(entity, px, py)
		end

		def move_entity(e, px, py)
			if e == @player
				move_player(px, py)
			else
				e.px, e.py = px, py
			end
		end

		def move_player(px, py)
			@map.player_leave(@player)
			new_map, x, y = @map.from_coords(px, py)
			@player.px, @player.py = x, y
			if new_map != @map
				switch_map(new_map)
			end
			@map.player_enter(@player)
		end

		private

		def switch_map(map)
			@map.exit if @map
			@map = map
			@entities = @map.entities
			@entities.add(@player)
			@map.enter
		end
	end
end

