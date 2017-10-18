module Pokemon
	class World
		attr_reader :camera, :player
		attr_accessor :map

		def load(data)
			@camera = Camera::Container.new
			@player = Player.new

			@camera.following = @player
			Map[data['map']].enter_map(data['x'], data['y'])
		end

		def save
			{
				'x' => @player.x,
				'y' => @player.y,
				'map' => @map.id
			}
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

