module Pokemon
	module Utils
		class Neighbor
			def initialize(this, id, d, offset)
				@this = this
				@id = id
				@dir = d.to_sym
				@offset = offset
			end

			def map
				@map ||= Map[@id]
			end

			def dx
				@dx ||= case @dir
					when :left
						map.width
					when :right
						-@this.width
					when :up
						@offset
					when :down
						@offset
				end
			end

			def dy
				@dy ||= case @dir
					when :left
						@offset
					when :right
						@offset
					when :up
						map.height
					when :down
						-@this.height
				end
			end
		end
	end
end

