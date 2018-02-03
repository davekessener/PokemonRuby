module Pokemon
module Battle
	class OrderingAction < Action::Base
		def initialize(pkmn, action)
			super(:move_order, {
				pokemon: pkmn,
				action: action,
				priority: action.priority,
				speed: pkmn.ini
			})
		end
	end

	class UpdateAction < Action::Base
		def initialize
			super(:update, {})
		end
	end

	class FaintAction < Action::Base
		def initialize(pkmn)
			super(:faint, {
				pokemon: pkmn
			})
		end
	end

	class MoveAction < Action::Base
		def initialize(user, attack, target)
			super(:attack_declared, {
				user: user,
				attack: attack,
				target: target
			},
				notify: true,
				effects: attack.effects,
				priority: attack.move.priority
			)
		end

		def execute(manager)
			user, attack, targets = get(:user), get(:attack), get(:target)
			manager.battle.targets(user, targets).each do |target|
				manager.add(AttackAction.new(user, attack, target))
			end
		end
	end

	class AttackAction < Action::Base
		def initialize(user, attack, target)
			super(:attack, {
				user: user,
				attack: attack.dup,
				target: target
			})
		end

		def execute(manager)
			user, attack, target = get(:user), get(:attack), get(:target)
			is_damaging = (attack.category != :status)

			if attack.misses?(user, target)
				manager.add(AttackMissAction.new(user, attack, target))
			elsif is_damaging and (damage = attack.damage(user, target)) <= 0.0
				puts "LOL failed"
			else
				if is_damaging
					manager.add(DamageAction.new(target, damage))

					if attack.critical.call(user, target)
						puts "Critical hit"
					end

					case attack.effectiveness <=> 1.0
						when 1
							puts "Not very effective"
						when -1
							puts "Super effective!"
					end
				end

				manager.add(AttackHitAction.new(user, attack, target))
			end
		end
	end

	class AttackMissAction < Action::Base
		def initialize(user, attack, target)
			super(:attack_miss, {
				user: user,
				attack: attack,
				target: target
			}, notify: true)
		end
	end

	class AttackHitAction < Action::Base
		def initialize(user, attack, target)
			super(:attack_hits, {
				user: user,
				attack: attack.dup,
				target: target
			}, notify: true)
		end
	end

	class DamageAction < Action::Base
		def initialize(target, damage)
			super(:damage, {
				target: target,
				damage: damage
			})
		end

		def execute(manager)
			target, damage = get(:target), get(:damage)
			manager.battle.field.by_id(target.uuid).hp -= damage
		end
	end
end
end

