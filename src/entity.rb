module Pokemon
	module Entity
		class Base < GameObject
			attr_accessor :px, :py
			attr_reader :controller, :renderer
			attr_accessor :model, :corporal

			def initialize(x, y)
				super()
				@px, @py = x, y
				@model = BasicModel.new(self)
				@controller = ActionController.new(self)
				@renderer = ModelRenderer.new(self)
			end
		end

		class ActionController < Component
			attr_reader :active

			def initialize(object)
				super(object)
				reset
			end

			def reset
				@queue = []
				@priority = 0
				@active = nil
			end

			def clear
				@queue = []
				@priority = 0
			end

			def active?
				@active
			end

			def empty?
				not active? and not queued?
			end

			def queued?
				not @queue.empty?
			end

			def <<(action)
				add(action, @priority)
			end

			def add(action, priority_id)
				priority = Utils::get_priority(priority_id)
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
				@active.enter if @active
			end
		end

		class ModelRenderer < Component
			def draw
				$world.renderer_at(object.px, object.py).draw(object.model) if object.model
			end
		end

		class BasicModel
			attr_accessor :dx, :dy, :dz, :z, :sprite
			attr_accessor :state, :type, :animation
			attr_accessor :progress
			attr_reader :facing

			def initialize(entity)
				@entity = entity
				@dx, @dy, @dz = 0, 0, 0
				@z = Utils::get_z(:entity)
				@sprite = nil
				@facing = :down
				@state = :default
				@type = :standing
				@animation = 0
				@progress = 0.0
			end

			def facing=(id)
				raise ArgumentError, "The only valid directions are #{Utils::Directions.join(', ')}!" unless Utils::Directions.include? id
				@facing = id
			end

			def reset(*vars)
				if vars.last.is_a? Hash
					vars.pop.each do |k,v|
						send "#{k}=", v
					end
				end
				vars.each do |v|
					send "#{v}=", 0
				end
			end

			def x
				@dx + @entity.px * $world.tile_size
			end

			def y
				@dy + @entity.py * $world.tile_size
			end

			def width
				@sprite ? @sprite.width : 0
			end

			def height
				@sprite ? @sprite.height : 0
			end
		end
	end
end

