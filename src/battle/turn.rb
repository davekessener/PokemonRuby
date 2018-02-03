module Pokemon
module Battle
	module Turn
		class Queue
			def initialize
				@queue = {}
			end

			def switch_out(pkmn)
				@queue.delete pkmn
			end

			def ready?(pkmns)
				pkmns.all? do |pkmn|
					@queue[pkmn] and not @queue[pkmn].empty?
				end
			end

			def [](pkmn)
				@queue[pkmn] = [] unless @queue[pkmn]
				@queue[pkmn]
			end

			def actions(pkmns)
				pkmns.map do |pkmn|
					[pkmn, @queue[pkmn].first]
				end.to_h
			end
		end

		class Manager
			def initialize
				@turns = []
				@actions = {}
				@history = []
			end

			def []=(pkmn, action)
				@actions[pkmn] = action
			end

			def <<(manager)
				@history << manager
			end

			def finish
				@turns << { actions: @actions, history: @history }
				@actions = {}
				@history = []
			end
		end
	end
end
end

