module Pokemon
module Overworld
	module Map
		module Event
			def activate(script)
				script.reset
				$world.run_script(script)
				true
			end
		end

		class EventEntity < Entity::IEntity
			include Event

			def self.set_trigger(id)
				define_method(id) { activate(@script) }
			end

			attr_reader :id

			def initialize(id, x, y, script)
				super(x, y)
				@id = id
				@script = script
			end
		end

		class ScriptEntity < EventEntity
			set_trigger :trigger
		end

		class TextEntity < EventEntity
			set_trigger :interact
		end

		class WarpEntity < EventEntity
			def initialize(id, x, y, script, dir)
				super(id, x, y, script)
				@dir = dir
			end

			def collide
				if @dir == :any or @dir == $world.player.model.facing
					activate(@script)
				end
			end
		end

		class NPCEntity < Entity::Base
			include Event
			
			attr_reader :id

			def initialize(id, x, y, sprite, script, ai)
				super(x, y)
				@id = id
				@script = script
				@ai = NPCController.new(self, ai)

				self.model.sprite = sprite
				self.corporal = true
			end

			def interact
				activate(@script)
				@ai.freeze
				controller.add(Overworld::Entity::TurnAction.new(self, Utils::opposite($world.player.model.facing)), :player)
				controller.add(Action::Conditional.new(self, lambda { @ai.unfreeze }) { not $world.script_running? }, :player)
			end
		end
	end
end

end
