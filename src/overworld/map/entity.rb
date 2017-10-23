module Pokemon
module Overworld
	module Map
		class Entity < Entity::Base
			attr_reader :id

			def initialize(id, x, y, script)
				super(x, y)
				@id = id
				@script = script
			end

			def activate
				@script.reset
				$world.run_script(@script)
			end

			def interact
			end

			def trigger
			end
		end

		class ScriptEntity < Entity
			def trigger
				activate
			end
		end

		class TextEntity < Entity
			def interact
				activate
			end
		end

		class NPCEntity < Entity
			def initialize(id, x, y, sprite, script, ai)
				super(id, x, y, script)
				@ai = NPCController.new(self, ai)

				self.model.sprite = sprite
				self.corporal = true
			end

			def interact
				activate
				@ai.freeze
				controller << Overworld::Entity::TurnAction.new(self, Utils::opposite($world.player.model.facing))
				controller << Action::Conditional.new(self, lambda { @ai.unfreeze }) { not $world.script_running? }
			end
		end
	end
end

end
