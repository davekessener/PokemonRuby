module Pokemon
	module Animation
		class BaseObject < GameObject
			attr_reader :model, :animation
			attr_accessor :frame

			def initialize(x, y, z, anim)
				super()
				@animation = anim
				@frame = 0
				@model = AnimationModel.new(x, y, z, @animation.width, @animation.height)
				Animator.new(self)
				Renderer.new(self)
			end

			def remove?
				super or @frame >= @animation.frames
			end
		end

		class Static < BaseObject
			def initialize(id, x, y, z)
				super(x, y, z, Resource[id])
			end
		end

		class Centered < BaseObject
			def initialize(id, x, y, z)
				a = Resource[id]
				super(x - a.width / 2, y - a.height / 2, z, a)
			end
		end

		class AnimationModel
			attr_reader :x, :y, :z, :width, :height

			def initialize(x, y, z, w, h)
				@x, @y, @z = x, y, z
				@width, @height = w, h
			end
		end

		class Animator < Component
			def initialize(object)
				super(object)
				@duration = object.animation.duration(0)
			end

			def update(delta)
				@duration -= delta
				if @duration <= 0
					object.frame += 1
					@duration += object.animation.duration(object.frame) unless object.remove?
				end
			end
		end

		class Renderer < Component
			def draw
				object.animation.draw(object.model.x, object.model.y, object.model.z, object.frame) unless object.remove?
			end
		end

		class Resource
			include Utils::DynamicLoad

			attr_reader :width, :height

			def frames
				@frames.length
			end

			def duration(idx)
				@frames[idx][1]
			end

			def draw(x, y, z, idx)
				@source[@frames[idx][0]].draw(x, y, z)
			end

			private_class_method :new

			private

			def load_data(data)
				fn = Utils::absolute_path(Utils::MEDIA_DIR, Utils::ANIMATION_DIR, data['source'])
				Utils::Logger::log("Loading animation #{id} from '#{Utils::relative_path(fn)}'.")
				@width, @height = data['width'], data['height']
				@source, cols, _ = *Utils::load_tiles(fn, @width, @height)
				@frames = data['frames'].map do |f|
					x, y = *f['at']
					[x + y * cols, f['duration']]
				end
			end

			def self.resource_path
				[Utils::DATA_DIR, Utils::ANIMATION_DIR]
			end
		end
	end
end

