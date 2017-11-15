module Pokemon
module Overworld
	module Map
		module Template
			def self.[](id)
				@@templates ||= {
					'text' => Textbox,
					'npc' => NPC,
					'warp' => Warp
				}
				@@templates[id]
			end

			class Textbox
				def initialize(arg)
					border, tid = *arg.split(/,/)
					tid, border = border, :sign if tid.nil?
					@script = Script::Textbox.new(Text[tid], border)
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
						@script = Script::Textbox.new(Text[args['text']])
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

			class Warp
				def initialize(args)
					@map = Map[args['map']]
					@target = args['target']
				end

				def instantiate(id, x, y)
					@script ||= Script::Warp.new(@map, *@map.entity_spawn(@target))
					WarpEntity.new(id, x, y, @script)
				end
			end
		end
	end
end

end
