module Pokemon
	class World
		attr_reader :player, :player_input

		def initialize
			@player_input = $input.create(:player)
			@script_input = $input.create(:script)
		end

		def load(data)
			@map = Map[data['map']]
			@player = Player.new(@player_input, data)
			@camera = Camera.new(@player.model)
			load_entities
			@map.enter
		end

		def save
		end

		def run_script(script)
			@script = script
			@script_input.activate
			@script_input << @script
		end

		def script_running?
			@script
		end

		def update(delta)
			@map.update(delta)
			@pool.update(delta)
			update_script(delta) if script_running?
		end

		def draw
			@camera.offset do |viewport|
				@map.draw(viewport)
				@pool.each { |e| e.draw if viewport.overlap? e.model }
			end
		end

		def player_interact(px, py)
			_, e = *@entities.find { |id, o| o.px == px and o.py == py }
			if e
				e.interact
			else
				@map.player_interact(px, py)
			end
		end

		def renderer_at(px, py)
			@map.renderer_at(px, py)
		end

		def tile_size
			@map.tile_size
		end

		def can_move_to(entity, px, py)
			return false if @pool.any? { |e| e.corporal and e.px == px and e.py == py }
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
			load_entities
			@map.enter
		end

		def load_entities
			@pool = ObjectPool.new
			@entities = @map.entities
			@entities[:player] = @player
			@entities.each { |id, e| @pool.add(e) }
		end

		def update_script(delta)
			@script.update(delta)
			if @script.done?
				@script_input.delete @script
				@scipt = nil
				@script_input.deactivate
			end
		end
	end
end

