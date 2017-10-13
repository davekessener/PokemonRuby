module Pokemon
	class OverworldScene < Scene
		def initialize
			$world = World.new
			$world.spawn_player('new_bark_town', 15, 6)
		end

		def update(delta)
			$world.update(delta)
		end

		def draw
			Gosu::scale(Utils::SCREEN_SCALE, Utils::SCREEN_SCALE) do
				$world.draw
			end
		end
	end
end

