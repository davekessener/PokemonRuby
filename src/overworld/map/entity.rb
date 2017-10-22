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
			def initialize(id, x, y, script, sprite, ai)
				super(id, x, y, script)
				model.sprite = sprite
				@ai = NPCController.new(self, ai)
			end

			def interact
				activate
				@ai.freeze
				@controller << ConditionalAction.new(self, lambda { @ai.unfreeze }) { not $world.script_running? }
			end
		end
	end
end

end
