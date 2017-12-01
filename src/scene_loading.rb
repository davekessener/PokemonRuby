module Pokemon
	class LoadingScene < Scene
		def enter
			@saves = Save::previews
			load_save(@saves.first[1])
		end

		def load_save(save)
			$world = Overworld::World.new
			save.load
			$window.switch_scene(Overworld::OverworldScene.new)
		end
	end
end

