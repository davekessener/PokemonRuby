module Pokemon
	module Script
		class Base
			def update(delta)
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

			def update(delta)
				unless done?
					@lines[@active].update(delta)
					@active += 1 if @lines[@active].done?
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
			def update(delta)
				act unless done?
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
			def initialize(content)
				@content = content
			end

			def act
				$ui.text_window(@content)
			end
		end

		class WaitForUI < Base
			def down(input, id)
				@done = (id == :A or id == :B)
				puts "received input :#{id}!"
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
	end
end

