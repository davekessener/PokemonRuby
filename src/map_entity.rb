module Pokemon
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

		module Template
			def self.[](id)
				@@templates ||= {
					'text' => Textbox
				}
				@@templates[id]
			end

			class Textbox
				def initialize(args)
					@content = Text[args]
					@script = Script::List.new([
						Script::OpenTextboxAction.new(@content),
						Script::WaitForUI.new,
						Script::CloseWindowsAction.new
					])
				end

				def instantiate(id, x, y)
					TextEntity.new(id, x, y, @script)
				end
			end
		end
	end
end

