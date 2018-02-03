require 'securerandom'

module Pokemon
module Battle
	class Pokemon
		attr_reader :uuid, :name, :stats, :base, :types
		attr_reader :species, :buffs, :hp, :crit, :level
		attr_accessor :item, :ability
		attr_accessor :affection, :status, :nature

		Stats = [:atk, :def, :spa, :spd, :ini]
		PerStats = Stats + [:hp]
		ExtStats = Stats + [:acc, :eva]

		def initialize(a)
			@uuid = SecureRandom::uuid
			@name = a[:name].to_s
			@item = Item[a[:item]].new(self) if a[:item]
			@ability_id = a[:ability]
			@affection = a[:affection]
			@level = a[:level]
			@base = a[:stats]
			@buffs = ExtStats.map { |s| [s, 0] }.to_h
			@nature = Nature[a[:nature]]
			@effects = []
			@crit = 0
			@status = {
				major: nil,
				minor: []
			}.to_o(:setters)

			self.species = a[:species]

			reset
			@hp = @base[:hp]
		end

		def hp=(v)
			@hp = [[v.to_i, @base[:hp]].min, 0].max
		end

		def crit=(c)
			if c.is_a? Numeric and c >= 0
				@crit = [c, 4].min
			end
		end

		def species=(id)
			@species = Species[id]
			@types = @species.types.dup
			@ability = Ability[@species.ability(@ability_id)].new(self)
			@stats = Stats.map do |stat|
				base, ivs, evs = @species.stats[stat], @base[:ivs][stat], @base[:evs][stat]
				tmp = (2.0 * base + ivs + evs / 4.0) * @level
				[stat, ((tmp / 100.0 + 5.0) * @nature.modifier(stat)).ceil]
			end.to_h
		end

		def reset
			@effects.clear
			@status.minor.clear
			@buffs.keys.each { |k| @buffs[k] = 0 }
		end

		def stat_boost(stat)
			t = (1.0 + 0.5 * @buffs[stat].abs)
			(@buffs[stat] < 0 ? 1.0 / t : t)
		end

		Stats.each do |stat|
			define_method stat do
				@stats.fetch(stat, 0) * stat_boost(stat)
			end
		end

		def effects
			@effects.dup.tap do |a|
				a << @ability
				a << @item if @item
			end
		end
	end
end
end

