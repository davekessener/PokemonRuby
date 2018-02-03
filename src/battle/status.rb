module Pokemon
module Battle
	module Status
		@__stati = {}

		class Base < Effect
			attr_reader :pokemon

			def initialize(pkmn, major, priority = Effect::priority[:status])
				super(priority)
				@pokemon, @major = pkmn, major
			end

			def major?
				@major
			end

			def id
				self.class.instance_variable_get '@id'
			end

			def active?
				if major?
					@pokemon.status.major == self
				else
					@pokemon.status.minor.include? self
				end
			end

			def type
				:status
			end

			def self.identify
				@id = name.downcase.to_sym
				Status.instance_variable_get('@__stati')[@id] = self
			end
		end

		class Sleep < Base
			identify

			def initialize(pkmn)
				super(:sleep, pkmn, true)

				@turns = rand

				on :move_declared do |manager|
				end
			end
		end

		class Poison < Base
			identify

			def initialize(pkmn)
				super(:poison, pkmn, true)

				on :turn_end_hinder do |manager|
				end
			end
		end

		class Toxic < Base
			identify

			def initialize(pkmn)
				super(:toxic, pkmn, true)

				@turns = 1

				on :turn_end_hinder do |manager|
					@turns += 1
				end
			end
		end

		class Burn < Base
			identify

			def initialize(pkmn)
				super(:burn, pkmn, true)

				on :move_declared do |manager|
				end

				on :turn_end_hinder do |manager|
				end
			end
		end

		def self.[](id)
			@__stati[id.to_sym] if id
		end
	end
end
end

