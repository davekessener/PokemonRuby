module Pokemon
	class Scene
		def enter
		end
		
		def leave
		end

		def update(delta)
		end

		def draw
		end
	end

	class GameObject
		attr_accessor :x, :y, :width, :height, :components

		def initialize(x, y, w, h)
			@components = []
			@x = x
			@y = y
			@width = w
			@height = h
		end

		def update(delta)
			@components.each { |c| c.update(delta) }
		end

		def draw
			@components.each(&:draw)
		end

		def remove?
			@removable
		end

		def remove!
			@removable = true
		end
	end

	class Component
		attr_reader :object

		def initialize(object)
			@object = object
			@object.components << self
		end

		def update(delta)
		end

		def draw
		end
	end
end

