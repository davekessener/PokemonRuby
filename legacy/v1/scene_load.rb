module Pokemon
	class LoadingScene < Scene
		def initialize
			@input = $input.create(:test)
			@window = $ui.text_window("This is a\ntest.\rThis should\nscroll through\na few lines,\nright?\rPOK@MON is a great\ngame.")

			@input << self
			@input.active = true
		end

		def down(input, id)
			if id == :start
				@input.active = false
				@window.remove!
				load_scene
			end
		end

		def up(input, id)
		end

		def load_scene
			fn = Utils::absolute_path(Utils::SAVE_DIR, 'auto.json')
			data = JSON.parse(File.read(fn))
			$world.load(data)
			$window.switch_scene(OverworldScene.new)
		end
	end
end

