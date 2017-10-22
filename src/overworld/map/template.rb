module Pokemon
module Overworld
	module Map
		module Template
			def self.[](id)
				@@templates ||= {
					'text' => Textbox
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
						@script = TextboxScript.new(Text[args['text']])
					end
					if args['ai']
					elsif args['movement']
					end
				end
			end
		end
	end
end

end
