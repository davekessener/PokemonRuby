module Pokemon
	module Sprite
		class Frame
			def initialize(data, cols)
				@cols = cols
				if data['group']
					@children = {}
					data['group'].each do |g|
						f = Frame.new(g, cols)
						@default = f if g['default']
						@children[g['id']] = f
						g['alias'].each { |e| @children[e] = f } if g['alias']
					end
				elsif data['alternatives']
					@frames = data['alternatives'].map do |alt|
						read_frames(alt)
					end
				else
					@frames = [ read_frames(data) ]
				end
				@default = self unless @default
			end

			def [](id)
				if @children and @children[id]
					@children[id]
				else
					@default
				end
			end

			def renderable?
				@frames
			end

			def frame(idx, p)
				if renderable?
					t = @frames[idx % @frames.size]
					t[(p * t.size).to_i % t.size]
				elsif @default != self
					@default.frame(idx, p)
				else
					raise "No renderable frame!"
				end
			end

			private

			def read_frames(data)
				if data['frames']
					data['frames'].map do |f|
						get_index(*f['at'])
					end
				elsif data['at']
					[ get_index(*data['at']) ]
				end
			end

			def get_index(x, y)
				x + y * @cols
			end
		end
	end
end

