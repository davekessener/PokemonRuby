module Pokemon
	module Utils
		class Neighbor
			attr_reader :id

			def initialize(this, id, d, offset)
				@this = this
				@id = id
				@dir = d
				@offset = offset
			end

			def map
				Map[@id]
			end

			def dx
				case @dir
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
				case @dir
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

