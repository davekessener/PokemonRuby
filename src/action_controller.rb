module Pokemon
	module Action
		class Controller < Component
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

			def add(action, priority_id)
				priority = Utils::get_priority(priority_id)
				if priority > @priority
					@priority = priority
					@queue = []
				end

				@queue << action unless priority < @priority
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

	end
end

