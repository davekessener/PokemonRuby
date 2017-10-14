module Pokemon
	module Utils
		class ObjectPool
			def initialize
				@pool = []
			end

			def <<(o)
				@pool << o
			end

			def upate(delta)
				@pool.each { |o| o.update(delta) }
				@pool.reject! &:remove?
			end

			def draw
				@pool.each &:draw
			end
		end
	end
end

