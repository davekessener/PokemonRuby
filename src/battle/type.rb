module Pokemon
module Battle
	module Type
		class Base < Effect
			attr_reader :id

			def initialize(id)
				super()
				@id = id
			end

			def modifier(type)
				Type.calculate(@id, type.id)
			end

			def type
				:typing
			end
		end

		Types = [:normal,  :fire,  :water,  :electric,  :grass,  :ice,  :fighting,  :poison,  :ground,  :flying,  :psychic,  :bug,  :rock,  :ghost,  :dragon,  :dark,  :steel,  :fairy]

		def self.[](id)
			unless @types
				@types = Types.map { |t| [t, Base.new(t)] }.to_h

				apply = lambda do |action, types, &block|
					types.each do |t|
						@types[t].on(action, &block)
					end
				end

				{
					[:fire] => [:burn],
					[:poison, :steel] => [:poison, :toxic]
				}.each do |types, status|
					apply.call(:apply_status, types) do |manager|
						action = manager.active
						if status.include? action.get(:status)
							action.fail self
						end
					end
				end

				apply.call(:attack_hits, [:grass]) do |manager|
					action = manager.active
					if action.get(:attack).tags.include? :powder
						action.fail self
					end
				end
			end

			@types[id.to_sym] if id
		end

		def self.calculate(offense, defense)
			unless @table
				@table = Types.map do |t|
					[t, Types.map { |e| [e, 1.0] }.to_h]
				end.to_h

				{
					fire: [:grass, :ice, :bug, :steel],
					water: [:fire, :ground, :rock],
					electric: [:water, :flying],
					grass: [:water, :ground, :rock],
					ice: [:grass, :ground, :flying, :dragon],
					fighting: [:normal, :ice, :rock, :dark, :steel],
					poison: [:grass, :fairy],
					ground: [:fire, :electric, :poison, :rock, :steel],
					flying: [:grass, :fighting, :bug],
					psychic: [:fighting, :poison],
					bug: [:grass, :psychic, :dark],
					rock: [:fire, :ice, :flying, :bug],
					ghost: [:psychic, :ghost],
					dragon: [:dragon],
					dark: [:psychic, :ghost],
					steel: [:ice, :rock, :fairy],
					fairy: [:fighting, :dragon, :dark]
				}.each do |t, strengths|
					strengths.each do |e|
						raise unless @table[t][e]
						@table[t][e] = 2.0
					end
				end

				{
					normal: [:rock, :steel],
					fire: [:fire, :water, :rock, :dragon],
					water: [:water, :grass, :dragon],
					electric: [:electric, :grass, :dragon],
					grass: [:fire, :poison, :flying, :bug, :dragon],
					ice: [:fire, :water, :ice, :steel],
					fighting: [:poison, :flying, :psychic, :bug, :fairy],
					poison: [:poison, :ground, :rock, :ghost],
					ground: [:grass, :bug],
					flying: [:electric, :rock, :steel],
					psychic: [:psychic, :ghost, :steel],
					bug: [:fire, :fighting, :poison, :flying, :steel],
					rock: [:fighting, :ground, :steel],
					ghost: [:dark, :steel],
					dragon: [:steel],
					dark: [:fighting, :poison, :dark, :fairy],
					steel: [:fire, :water, :electric, :grass],
					fairy: [:fire, :poison, :steel]
				}.each do |t, weaknesses|
					weaknesses.each do |e|
						raise unless @table[t][e]
						@table[t][e] = 0.5
					end
				end

				{
					normal: :ghost,
					electric: :ground,
					fighting: :ghost,
					poison: :steel,
					ground: :flying,
					psychic: :dark,
					ghost: :normal,
					dragon: :fairy
				}.each do |t, immune|
					raise unless @table[t][immune]
					@table[t][immune] = 0.0
				end
			end

			raise unless offense and defense

			@table[offense][defense]
		end
	end
end
end

