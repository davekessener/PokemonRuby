module Pokemon
module Battle
	class Stage
		attr_reader :effects, :field

		def initialize(n)
			@effects, @waiting = [], 0
			@field = Field.new(n)
			@action_queue = Turn::Queue.new
			@history = Turn::Manager.new
		end

		def act(pkmn, action)
			@action_queue[pkmn] << action
		end

		def turn
			unless (@standby = !@standby)
				raise unless @action_queue.ready? (pkmns = @field.pokemon)
				@pokemon = pkmns
			end
		end

		def wait
			@waiting += 1
		end

		def resume
			@waiting -= 1 if @waiting > 0
		end

		def update(delta)
			return unless @pokemon and @waiting.zero?

			if @pokemon.empty?
				execute(UpdateAction.new)
				@history.finish
				@pokemon = nil
			elsif @field.active?(active = @pokemon.delete(fastest(@pokemon)))
				action = @action_queue[active].shift
				execute(action)
				@history[active] = action

				while (pkmn = @field.pokemon.find { |p| p.hp <= 0 })
					execute(FaintAction.new(pkmn))
				end
			end
		end

		def targets(pkmn, target)
			if target.is_a? Numeric
				@field.targets(target)
			elsif target == :self
				pkmn
			elsif target == :all
				@field.targets(0).tap { |a| a.delete pkmn }
			elsif target == :all_inclusive
				@field.targets(0)
			else
				raise
			end
		end

		private

		def fastest(pokemon)
			fastest, speed = nil, { priority: 0, speed: 0 }
			@action_queue.actions(pokemon).each do |pkmn, action|
				execute(order = OrderingAction.new(pkmn, action))

				dp = speed[:priority] - order.get(:priority)
				ds = speed[:speed] - order.get(:speed)
				if fastest.nil? or dp < 0 or (dp == 0 and ds < 0)
					fastest = [pkmn]
					[:priority, :speed].each { |t| speed[t] = order.get(t) }
				elsif dp == 0 and ds == 0
					fastest << pkmn
				end
			end
			fastest.sample
		end

		def execute(action)
			m, e = Action::Manager.new(self, action), compile
			until m.resolved? and m.empty?
				m.resolve do |a|
					e.each do |effect|
						effect.apply(a, m)
					end
				end unless m.resolved?

				m.pop.tap do |a|
					if a.notify?
						puts "Action #{a.id}"
						puts "But it failed ..." if a.failed?
					end

					a.execute(m) unless a.failed?
				end unless m.empty?
			end
			@history << m
			m
		end

		def compile
			c, f = BinaryHeap.new, lambda { |e| c << e }
			@field.effects.each(&f)
			@field.pokemon.each { |pkmn| pkmn.effects.each(&f) }
			@action_queue.actions(@pokemon).each do |pkmn, action|
				action.effects.each(&f)
			end
			c << GameMechanics.new
			c.to_a!
		end
	end
end
end

