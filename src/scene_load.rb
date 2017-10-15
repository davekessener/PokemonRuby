module Pokemon
	class LoadingScene < Scene
		def update(delta)
			fn = Utils::absolute_path(Utils::SAVE_DIR, 'auto.json')
			data = JSON.parse(File.read(fn))
			$world.load(data)
			$window.switch_scene(OverworldScene.new)
		end
	end
end

