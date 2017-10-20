module Pokemon
	class OverworldScene < Scene
		def update(delta)
			$world.update(delta)
		end

		def draw
			$world.draw
		end
	end
end

