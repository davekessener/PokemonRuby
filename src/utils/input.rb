module Pokemon
	module Input
		class Base
			attr_reader :buttons

			def initialize
				@buttons = []
				@pressed, @released = {}, {}
			end

			def down(id)
				@pressed[id] = true unless @buttons.include? id
				@buttons.unshift id
			end

			def up(id)
				@released[id] = true if @buttons.include? id
				@buttons.delete id
			end

			def down?(id)
				@pressed[id] = false
				@buttons.include? id
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
				@buttons = []
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
				@receivers.sort! { |a,b| b.priority <=> a.priority }
				r
			end

			def down(id)
				super
				@active.down(id) if @active
			end

			def up(id)
				super
				@active.up(id) if @active
			end

			def activate(r)
				return unless r.active?

				return if @active and @active.priority >= r.priority

				set_active(r)
			end

			def deactivate(r)
				return if r.active? or @active != r

				@active.base = @empty
				@active = nil

				@receivers.each do |recv|
					if recv.active?
						set_active(recv)
						break
					end
				end
			end

			private

			def set_active(a)
				@active.base = @empty if @active
				@active = a
				@active.base = self
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

			def delete(cb)
				@callbacks.delete cb
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
				@callbacks.each { |cb| cb.down(@base, id) if cb.respond_to? :down } if active?
			end

			def up(id)
				@callbacks.each { |cb| cb.up(@base, id) if cb.respond_to? :up } if active?
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

			def buttons
				@base.buttons.dup
			end
		end
	end
end

