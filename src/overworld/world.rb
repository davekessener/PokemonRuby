module Pokemon
module Overworld
	class World
		attr_reader :player, :player_input

		def initialize
			@pool = ObjectPool.new
			@player_input = $input.create(:player)
			@script_input = $input.create(:script)
		end

		def load(save)
			@player = Player.new(@player_input, save.data)
			@map = Map[save.data['map']]
			@camera = Camera.new(@player.model)
			load_entities
			@pool.add(@entities[:player])
			@map.enter
			@map.player_enter @player
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
			update_script if script_running?
		end

		def draw
			@camera.offset do |viewport|
				@map.draw(viewport)
				@pool.each { |e| e.draw if viewport.overlap? e.model }
			end
		end

		def add_object(o)
			@pool.add o
		end

		def meta_at(px, py)
			@map.meta_at px, py
		end

		def player_interact(px, py)
			e = entity_at px, py
			if e
				e.interact
			else
				@map.player_interact(px, py)
			end
		end

		def player_trigger(px, py)
			e = entity_at px, py
			if e
				e.trigger
			else
				@map.player_trigger(px, py)
			end
		end

		def renderer_at(px, py)
			@map.renderer_at(px, py)
		end

		def can_move?(entity, px, py)
			not @map.out_of_bounds?(px, py) and can_player_move?(entity, px, py)
		end

		def tile_size
			@map.tile_size
		end

		def can_player_move?(player, px, py)
			return false if @pool.any? { |e| e.corporal and e.px == px and e.py == py }
			@map.can_move_to(player, px, py)
		end

		def try_player_move(p, px, py)
			e = @pool.find { |o| o.px == px and o.py == py }

			return true if e and e.collide

			if can_player_move? p, px, py
				move_player px, py
				return true
			end

			return false
		end

		def move_entity(e, px, py)
			if e == @player
				move_player(px, py)
			else
				@map.entity_leave(e)
				e.px, e.py = px, py
				@map.entity_enter(e)
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

		def warp_player(map, warp)
			switch_map(map)
			e = @entities[warp]
			@player.px, @player.py = e.px, e.py
			e.on_appear
		end

		private

		def entity_at(px, py)
			_, e = *@entities.find { |id, o| o.px == px and o.py == py }
			e
		end

		def switch_map(map)
			@map.exit if @map
			@map = map
			load_entities
			@map.enter
		end

		def load_entities
			@entities.each { |id, e| e.remove! unless id == :player } if @entities
			@entities = @map.entities
			@entities.each { |id, e| @pool.add(e) }
			@entities[:player] = @player
		end

		def update_script
			@script.tick
			if @script.done?
				@script_input.delete @script
				@script = nil
				@script_input.deactivate
			end
		end
	end
end

end
