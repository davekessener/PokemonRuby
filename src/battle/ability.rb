module Pokemon
module Battle
	module Ability
		class Base < Effect
			def initialize(pkmn)
				super()
				@pokemon = pkmn
			end

			def type
				:ability
			end
		end

		def self.[](id)
			Base
		end
	end
end
end

