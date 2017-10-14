module Pokemon
	module Animation
		class Constant < GameObject
			attr_reader :frame

			def initialize(x, y, image)
				super(x, y, image.width, image.height)
				@frame = image
				Renderer.new(self)
			end

			def progress=(p)
			end
		end

		class Base < GameObject
			attr_accessor :progress

			def initialize(x, y, frames)
				super(x, y, frames[0].width, frames[0].height)
				@frames = frames
				Renderer.new(self)
			end

			def frame
				@frames[(self.progress * @frames.size).to_i]
			end
		end

		class Moving < Base
			def initialize(x, y, frames, movement)
				super(x, y, frames)
				Mover.new(self, movement)
			end
		end

		class Timed < Base
			def initialize(x, y, frames, duration)
				super(x, y, frames)
				Timer.new(self, duration)
			end
		end

		class Renderer < Component
			def draw
				object.frame.draw(object.x, object.y)
			end
		end

		class Mover < Component
			def initialize(object, movement, remove_if_done = true)
				super(object)
				@movement = movement
				@remove = remove_if_done
			end

			def update(delta)
				dx, dy = @movement.calculate(delta)
				object.x += dx
				object.y += dy
				object.progress = @movement.progress
				object.remove! if @remove and @movement.done?
			end
		end

		class Timer < Component
			def initialize(object, duration, remove_if_done = true)
				super(object)
				@left = @duration = duration
				@remove = remove_if_done
			end

			def update(delta)
				if @left > 0
					@left -= delta
					@left = 0 if @left < 0
					object.progress = (@duration - @left) / @duration.to_f
					object.remove! if @remove and @left == 0
				end
			end
		end
	end
end

