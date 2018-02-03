module Pokemon
module Battle
	class Attack
		attr_accessor :move, :power, :accuracy
		attr_accessor :category, :critical
		attr_accessor :effectiveness, :modifier
		attr_accessor :attack, :defense, :seed
		attr_reader :types, :tags, :effects
		attr_writer :damage

		def initialize(move)
			@move, @seed = move, rand
			@power, @accuracy, @category = move.power, move.accuracy, move.category
			@effectiveness, @modifier  = 1.0, 1.0
			@attack = lambda do |u, t|
				c = @critical.call(u, t)
				a = @move.category == :physical ? :atk : :spa
				b = u.stat_boost(a)
				u.stats[a] * ((c && b < 1.0) ? 1.0 : b)
			end
			@defense = lambda do |u, t|
				c = @critical.call(u, t)
				a = @move.category == :physical ? :def : :spd
				b = t.stat_boost(a)
				t.stats[a] * ((c && b > 1.0) ? 1.0 : b)
			end
			@critical = lambda { |u, t| @seed < ((2 ** u.crit) / 32.0) }
			@damage = lambda do |u, t|
				a, d = @attack.call(u, t), @defense.call(u, t)
				m = @modifier * @effectiveness * (@critical.call(u, t) ? 1.5 : 1.0)
				(((2.0 * u.level / 5.0 + 2.0) * @power * a / d) / 50.0 + 2) * m
			end
			@types, @tags, @effects = move.types.dup, move.tags.dup, move.effects.map { |e| e.new(self) }
		end

		def damage(user, target)
			@damage.call(user, target)
		end

		def misses?(user, target)
			if @accuracy
				a = @accuracy * user.stat_boost(:acc) / target.stat_boost(:eva)
				((a < 1.0) && (rand > a))
			end
		end
	end
end
end

