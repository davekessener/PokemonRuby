module Pokemon
	class OverworldScene < Scene
		def enter
			$world.player_input.activate
		end

		def exit
			$world.player_input.deactivate
		end

		def update(delta)
			$world.update(delta)
		end

		def draw
			$world.draw
		end
	end
end

