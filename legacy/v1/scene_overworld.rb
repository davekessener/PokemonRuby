module Pokemon
	class OverworldScene < Scene
		def initialize
			@objects = Utils::ObjectPool.new
		end

		def update(delta)
			$world.update(delta)
			@objects.update(delta)
		end

		def draw
			$world.draw
			@objects.draw
		end
	end
end

