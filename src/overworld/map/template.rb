module Pokemon
module Overworld
	module Map
		module Template
			def self.[](id)
				@@templates ||= {
					'text' => Textbox,
					'npc' => NPC
				}
				@@templates[id]
			end

			class Textbox
				def initialize(args)
					@script = Script::TextboxScript.new(Text[args])
				end

				def instantiate(id, x, y)
					TextEntity.new(id, x, y, @script)
				end
			end

			class NPC
				def initialize(args)
					@sprite = Sprite[args['sprite']] if args['sprite']
					if args['script']
					elsif args['text']
						@script = Script::TextboxScript.new(Text[args['text']])
					end
					if args['ai']
						@ai = AI[args['ai']]
					elsif args['movement']
					end
				end

				def instantiate(id, x, y)
					NPCEntity.new(id, x, y, @sprite, @script, @ai)
				end
			end
		end
	end
end

end
