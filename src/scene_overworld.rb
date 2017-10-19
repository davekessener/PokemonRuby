module Pokemon
	class OverworldScene < Scene
		def update(delta)
			$world.update(delta)
		end

		def draw
			Utils::scale_screen do
				$world.draw
			end
		end
	end
end

