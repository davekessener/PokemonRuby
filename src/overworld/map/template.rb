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
					@map = args['map']
					@target = args['target']
					@dir = args['direction'].to_sym
				end

				def instantiate(id, x, y)
					load_scripts
					WarpEntity.new(id, x, y, @warp_script, @appear_script, @dir)
				end

				private

				def load_scripts
					@warp_script ||= Script::Warp.new(Map[@map], @target)
					@appear_script ||= Script::Action.new() do
						p = $world.player
						p.controller.add(Entity::WalkAction.new(p, p.model.facing), :script)
					end
				end
			end
		end
	end
end

end
