module Pokemon
	module Entity
		class Base < GameObject
			attr_reader :px, :py
			attr_reader :controller
			attr_accessor :model, :corporal

			def initialize(x, y)
				super()
				@px, @py = x, y
				@model = BasicModel.new
				@controller = ActionController.new(self)
				ModelRenderer.new(self)

				@model.x = @px * $world.tile_size
				@model.y = @py * $world.tile_size
			end
		end

		class ActionController < Component
			def initialize(object)
				super(object)
				reset
			end

			def reset
				@queue = []
				@priority = 0
				@active = nil
			end

			def active?
				@active
			end

			def add(action, priority)
				if priority > @priority
					@priority = priority
					@queue = []
				end

				@queue << action
			end

			def update(delta)
				next_action unless active?
				
				if active?
					@active.update(delta)
					next_action if @active.done?
				end

				@priority = 0 if @queue.empty?
			end

			def override(active)
				@active.interrupt if @active
				reset
				@active = active
				@active.enter
			end

			private

			def next_action
				@active.exit if @active
				@active = @queue.shift
			end
		end

		class ModelRenderer < Component
			def draw
				$world.renderer_at(object.px, object.py).draw(object.model)
			end
		end

		class BasicModel
			attr_accessor :x, :y, :z, :sprite, :facing
			attr_accessor :state, :type, :animation
			attr_accessor :progress

			def initialize
				@x, @y = 0, 0
				@z = Utils::get_z(:entity)
				@sprite = Sprite['undefined']
				@facing = :down
				@state = :default
				@type = :standing
				@animation = 0
				@progress = 0.0
			end

			def width
				@sprite.width
			end

			def height
				@sprite.height
			end
		end

		class Action
			def enter
			end

			def exit
			end

			def interrupt
			end

			def update(delta)
			end

			def done?
				true
			end
		end
	end
end

