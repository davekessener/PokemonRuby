module Pokemon
module Battle
	class Field
		class Side
			def initialize(n)
				@pokemon = FixedArray.new(n)
				@lookup = {}
			end

			def resize(n)
				@pokemon.resize(n)
			end

			def get(i)
				raise unless (0...@pokemon.size).include? i
				@pokemon[i]
			end

			def by_id(id)
				@lookup[id]
			end

			def put(i, pkmn)
				get(i).try { |p| @lookup.delete(p.uuid) }
				@lookup[pkmn.uuid] = @pokemon[i] = pkmn
			end

			def all
				@pokemon.to_a
			end
		end

		attr_reader :effects

		def initialize(n)
			@sides = Array.new(2) { Side.new(n) }
			@effects = []
		end

		def pokemon
			@sides.map { |s| s.all }.flatten(1)
		end

		def targets(t)
			if t.zero?
				pokemon
			else
				side, t = (t > 0 ? 0 : 1), (t.abs - 1)

				if t > 1
					@sides[side].all
				else
					[@sides[side].get(t)]
				end
			end
		end

		def active?(pkmn)
			@sides.any? { |s| s.by_id(pkmn.uuid) }
		end

		def send_out(pkmn, i)
			side, i = (i > 0 ? 0 : 1), (i.abs - 1)
			@sides[side].put(i, pkmn)
		end

		def by_id(uuid)
			@sides.each do |side|
				if (pkmn = side.by_id(uuid))
					return pkmn
				end
			end
			nil
		end
	end
end
end

