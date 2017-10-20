module Pokemon
	module Input
		class Base
			def initialize
				@buttons = {}
				@pressed, @released = {}, {}
			end

			def down(id)
				@pressed[id] = true unless @buttons[id]
				@buttons[id] = true
			end

			def up(id)
				@released[id] = true if @buttons[id]
				@buttons[id] = false
			end

			def down?(id)
				@pressed[id] = false
				@buttons[id]
			end

			def pressed?(id)
				r = @pressed[id]
				@pressed[id] = false
				r
			end

			def released?(id)
				r = @released[id]
				@released[id] = false
				r
			end

			def reset
				@buttons = {}
				@pressed, @released = {}, {}
			end
		end

		class System < Base
			def initialize
				super
				@receivers = []
				@empty = Base.new
			end

			def create(id)
				r = Receiver.new(id, self, @empty, Utils::get_priority(id))
				@receivers << r
				@receivers.sort { |a,b| a.priority <=> b.priority }
				r
			end

			def down(id)
				super
				@active.down(id) if @active
				Utils::Logger::log("Button :#{id} down.")
			end

			def up(id)
				super
				@active.up(id) if @active
				Utils::Logger::log("Button :#{id} up.")
			end

			def activate(r)
				return unless r.active?

				return if @active and @active.priority >= r.priority

				@active.base = @empty if @active
				@active = r
				@active.base = self

				Utils::Logger::log("Activating input '#{@active.id}'.")
			end

			def deactivate(r)
				return if r.active? or @active != r

				Utils::Logger::log("Deactivating input '#{@active.id}'.")

				@active.base = @empty
				@active = nil

				@receivers.each do |recv|
					if recv.active?
						@active = recv
						Utils::Logger::log("Activating input '#{@active.id}' instead.")
						break
					end
				end
			end
		end

		class Callback
			def down(input, id)
			end

			def up(input, id)
			end
		end

		class Receiver
			attr_accessor :base
			attr_reader :id, :priority

			def initialize(id, src, base, p)
				@id = id
				@source = src
				@base = base
				@priority = p
				@active = false
				@callbacks = []
			end

			def <<(cb)
				@callbacks << cb
			end

			def active=(v)
				if v != @active
					@active = v

					if @active 
						@source.activate(self)
					else
						@source.deactivate(self)
					end
				end
			end

			def activate
				self.active = true
			end

			def deactivate
				self.active = false
			end

			def active?
				@active
			end

			def down(id)
				@callbacks.each { |cb| cb.down(@base, id) } if active?
			end

			def up(id)
				@callbacks.each { |cb| cb.up(@base, id) } if active?
			end

			def pressed?(id)
				@base.pressed? id
			end

			def released?(id)
				@base.released? id
			end

			def down?(id)
				@base.down? id
			end
		end
	end
end

