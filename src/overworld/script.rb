module Pokemon
module Overworld
	module Script
		class Base
			def tick
			end

			def done?
				true
			end

			def reset
			end

			def down(input, id)
			end

			def up(input, id)
			end
		end

		class List < Base
			def initialize(sub)
				@lines = sub
				@active = 0
			end

			def <<(line)
				@lines << line
			end

			def tick
				while not done?
					@lines[@active].tick
					break unless @lines[@active].done?
					@active += 1
				end
			end

			def done?
				@active >= @lines.length
			end

			def reset
				@lines.each { |e| e.reset }
				@active = 0
			end

			def down(input, id)
				@lines[@active].down(input, id) unless done?
			end

			def up(input, id)
				@lines[@active].up(input, id) unless done?
			end
		end

		class Action < Base
			def initialize(&block)
				@action = block_given? ? block : lambda { act }
			end

			def tick
				@action.call unless done?
				@done = true
			end

			def done?
				@done
			end

			def reset
				@done = false
			end
		end

		class OpenTextboxAction < Action
			def initialize(content, border = :default)
				@content, @border = content, border
			end

			def act
				$ui.text_window(@content, @border)
			end
		end

		class WaitForUI < Base
			def down(input, id)
				@done = (id == :A or id == :B)
			end

			def done?
				@done
			end

			def reset
				@done = false
			end
		end

		class CloseWindowsAction < Action
			def act
				$ui.close_all
			end
		end

		class Textbox < List
			def initialize(content, border = :default)
				super([
					OpenTextboxAction.new(content, border),
					WaitForUI.new,
					CloseWindowsAction.new
				])
			end
		end

		class Warp < List
			def initialize(map, id)
				super([Action.new { self << $world.warp_player(@map, @wid) }])
				@map, @wid = map, id
			end
		end
	end
end

end
