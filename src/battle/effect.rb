module Pokemon
module Battle
	class Effect
		include Comparable

		attr_accessor :priority

		def initialize(p = Effect::priority[type])
			@priority = p
			@actions = {}
		end

		def <=>(o)
			@priority <=> o.priority
		end

		def apply(action, manager)
			@actions[action.id].each { |a| a.call(manager) } if @actions[action.id]
		end

		def active?
			true
		end

		def type
			:default
		end

		def on(action, &block)
			@actions[action] = [] unless @actions[action]
			@actions[action] << block
			self
		end

		def self.priority
			@@priorities ||= {
				default: 0,
				mechanics: 10,
				field: 20,
				status: 30,
				buff: 40,
				move: 50,
				ability: 60,
				item: 70
			}
		end
	end

	class GameMechanics < Effect
		def initialize
			super()

			on :attack_declared do |manager|
				attack = manager.active

				attack.transform :attack, self do |a|
					ut = attack.get(:user).types
					a.modifier *= 1.0 + 0.5 * a.types.count { |t| ut.include? t }
				end

				attack.transform :attack, self do |a|
					a.modifier *= 0.75
				end unless attack.get(:target).is_a? Numeric
			end

			on :attack_hits do |manager|
				attack = manager.active

				attack.transform :attack, self do |a|
					ts = a.types.product(attack.get(:target).types)
					a.effectiveness = ts.map { |t1, t2| t1.modifier(t2) }.reduce { |i1, i2| i1 * i2 }
				end
			end
		end

		def type
			:mechanics
		end
	end
end
end

