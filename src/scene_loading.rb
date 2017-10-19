module Pokemon
	class LoadingScene < Scene
		def enter
			$world = World.new
			$world.load(Utils::load_json(Utils::SAVE_DIR, "auto.json"))
			$window.switch_scene(OverworldScene.new)
		end
	end
end

