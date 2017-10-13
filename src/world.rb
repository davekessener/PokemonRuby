module Pokemon
	class World
		attr_reader :camera, :player
		attr_accessor :map

		def initialize
			@camera = Camera::Container.new
			@player = Player.new

			@camera.following = @player
		end

		def spawn_player(map, px, py)
			@map = Map[map]
			@map.enter_map(px, py)
		end

		def update(delta)
			@map.update(delta)
			@player.update(delta)
		end

		def draw
			x, y = *Utils::camera_offset(@camera)
			@map.draw(x, y)
		end
	end
end

