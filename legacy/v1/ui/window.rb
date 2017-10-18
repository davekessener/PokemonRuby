module Pokemon
	module UI
		class DisplayTextEvent < Entity::Event
			def initialize(object, text, speed = 50)
				super(object)
				@text = text.split(//)
				@left = @speed = speed
			end

			def enter
				object.renderer.new_line
			end

			def update(delta)
				while delta > @left
					delta -= @left
					@left = @speed
					object.renderer << @text.shift
					break if done?
				end
				@left -= delta
			end

			def done?
				@text.empty?
			end
		end

		class ScrollTextEvent < Entity::Event
			def initialize(object, speed = 100)
				super(object)
				@speed = speed
				@current = 0
			end

			def update(delta)
				@current += delta
				if @current > @speed
					@done = true
				else
					object.renderer.displace = @current / @speed.to_f
				end
			end

			def done?
				@done
			end
		end

		class InputEvent < Entity::Event
			def initialize(object, keys, &block)
				super(object)
				@keys = keys
				@callback = block if block_given?
			end

			def enter
				object.renderer.wait = true
			end

			def exit
				object.renderer.wait = false
			end

			def accept(id)
				if not @done and @keys.include? id
					@done = true
					@callback.call if @callback
				end
			end

			def done?
				@done
			end
		end

		class Window < Entity::Base
			attr_reader :z

			def initialize(x, y, w, h, z, border)
				super(x, y, w, h)
				@z = z
				BorderRenderer.new(self, border)
			end

			def done?
				true
			end

			def press(id)
			end
		end

		class BorderRenderer < Component
			def initialize(object, border)
				super(object)
				@border = border
			end

			def draw
				@border.draw(object.x, object.y, object.width, object.height, object.z)
			end
		end

		class TextWindow < Window
			attr_reader :renderer, :charset

			def initialize(s, z, charset, border)
				super(0, Utils::SCREEN_SIZE[1] - 6 * charset.char_height, Utils::SCREEN_SIZE[0], 6 * charset.char_height, z, border)
				@charset = charset

				paragraphs = s.split("\r").map { |p| p.split("\n") }
				paragraphs.reject &:empty?
				q = self.queue

				paragraphs.each_with_index do |p, j|
					s = p.size - 1
					p.each_with_index do |l, i|
						q << DisplayTextEvent.new(self, l)
						unless i == 0 or i == s
							q << InputEvent.new(self, [:A, :B]) << ScrollTextEvent.new(self)
						end
					end
					q << (InputEvent.new(self, [:A, :B]) { renderer.reset }) unless j == paragraphs.size - 1
				end

				@renderer = TextRenderer.new(self, 
					self.x + 3 * charset.char_width / 2, 
					self.y + 3 * charset.char_height / 2,
					2 * charset.char_height)
			end

			def done?
				queue.empty?
			end

			def press(id)
				e = queue.first
				e.accept id if e and e.respond_to? :accept
			end
		end

		class TextRenderer < Component
			attr_accessor :displace, :wait
			attr_reader :px, :py

			def initialize(object, px, py, h)
				super(object)
				@px, @py = px, py
				@char_height = h
				new_line
			end

			def new_line
				@old_line = @cur_line
				@cur_line = ''
				@displace = 0.0
				@old_line = nil if @old_line and @old_line.empty?
			end

			def <<(c)
				@cur_line += c
			end

			def draw
				y = @py

				if @old_line
					object.charset.draw(@old_line, @px, y, object.z + 1)
					y += @char_height
				end

				object.charset.draw(@cur_line, @px, y, object.z + 1)

				if @wait
					p = (Gosu::milliseconds / 1200) % 2
					object.charset.draw("\x02", object.x + object.width - 3 * object.charset.char_width, object.y + object.height - 3 * object.charset.char_height / 2 + p, object.z + 1)
				end
			end

			def reset
				@cur_line = nil
				new_line
			end
		end
	end
end

