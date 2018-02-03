module Pokemon
module Battle
	module Action
		class Base
			attr_reader :id, :targets, :effects, :priority
	
			def initialize(id, targets, **opts)
				@id = id
				@targets = targets
				@history = targets.keys.map { |k| [k, []] }.to_h
				@failed = []

				@notify = opts.fetch(:notify, false)
				@effects = opts.fetch(:effects, []).dup
				@priority = opts.fetch(:priority, 0)
			end

			def notify?
				@notify
			end
	
			def failed?
				not @failed.empty?
			end

			def get(tid)
				@targets[tid]
			end
	
			def transform(tid, actor, &block)
				block.call(x = (t = @targets[tid]).dup)
				@targets[tid] = x
				@history[tid] << [t, actor, block]
				self
			end
	
			def fail(actor = nil, &block)
				if actor
					@failed << actor
				elsif block_given?
					@failed.each(&block)
				end
				self
			end

			def history(tid)
				(h = @history[tid]).each_with_index do |a, i|
					new, old, actor = ((i + 1) == h.length ? @targets[tid] : h[i + 1].first), *a
					yield old, new, actor
				end
			end
	
			def execute(manager)
			end
		end

		class Manager
			attr_reader :battle, :active

			def initialize(battle, primary)
				@battle = battle
				@done, @resolved, @unresolved = [], [], [primary]
			end

			def resolved?
				@unresolved.empty?
			end

			def empty?
				@resolved.empty?
			end

			def add(action)
				@unresolved << action
			end

			def resolve
				raise if resolved?
				if block_given?
					@unresolved.shift.tap do |action|
						yield (@active = action)
						@resolved << action
					end
				end
			end

			def pop
				raise if @resolved.empty?
				@resolved.shift.tap { |o| @done.push(o) }
			end
		end
	end
end
end

