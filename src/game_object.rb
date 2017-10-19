module Pokemon
	class ObjectPool
		def initialize
			@pool = []
		end

		def <<(o)
			@pool << o
		end

		def update(delta)
			@pool.each { |o| o.update(delta) }
			@pool.reject! &:remove?
		end

		def draw
			@pool.each &:draw
		end

		def each(&block)
			@pool.each(&block) if block_given?
		end

		alias_method :add, :<<
	end

	class GameObject
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
		end

		def update(delta)
		end

		def draw
		end
	end
end

