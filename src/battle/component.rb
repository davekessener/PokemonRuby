module Pokemon
module Battle
	class Container
		attr_reader :components

		def initialize
			@components = []
		end

		def update(delta)
			@components.each do |c|
				c.update(delta)
			end
		end

		def draw
			@components.each do |c|
				c.draw
			end
		end
	end

	class Component
		def attach(o)
			(@object = o).components << self
		end

		def detach
			if @object
				@object.components.delete self
				@object = nil
			end
		end

		def update(delta)
		end

		def draw
		end
	end
end
end

