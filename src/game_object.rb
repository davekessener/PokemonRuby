module Pokemon
	class ObjectPool < Array
		def update(delta)
			each { |o| o.update(delta) }
			reject! &:remove?
		end

		def draw
			each &:draw
		end

		alias_method :add, :<<
	end

	class GameObject
		attr_reader :components

		def initialize
			@components = []
		end

		def update(delta)
			@components.each { |c| c.update(delta) }
		end

		def draw
			@components.each &:draw
		end

		def remove?
			@remove
		end

		def remove!
			@remove = true
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

