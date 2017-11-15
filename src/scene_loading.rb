module Pokemon
	class LoadingScene < Scene
		def enter
			$world = Overworld::World.new
			$world.load(Utils::Save['auto'])
			$window.switch_scene(Overworld::OverworldScene.new)
		end
	end
end

