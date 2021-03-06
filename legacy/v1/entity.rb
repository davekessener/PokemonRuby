module Pokemon
	module Entity
		class Base < GameObject
			attr_reader :queue, :controller

			def initialize(x, y, w, h)
				super(x, y, w, h)
				@queue = []
				@controller = Controller.new(self)
			end
		end

		class Event
			attr_reader :object
			attr_accessor :renderer

			def initialize(object)
				@object = object
			end

			def enter
			end

			def exit
			end

			def update(delta)
			end

			def accept(id)
			end

			def done?
				true
			end
		end

		class Controller < Component
			def update(delta)
				o = object.queue.first
				if o
					o.enter unless @cont
					@cont = true
					o.update(delta)
					if o.done?
						object.queue.shift
						o.exit
						@cont = false
						o = object.queue.first
						if o
							o.enter
							@cont = true
						end
					end
				end
			end
		end

		class DelayedCallbackEvent < Event
			attr_reader :duration, :delay

			def initialize(object, delay, &callback)
				super(object)
				@duration = @delay = delay
				@callback = callback
			end

			def update(delta)
				if @delay > 0
					@delay -= delta
					if @delay <= 0
						@callback.call if @callback
					end
				end
			end

			def done?
				@delay <= 0
			end

			def progress
				@delay / @duration.to_f
			end
		end
	end
end

