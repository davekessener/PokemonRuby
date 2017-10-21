module Pokemon
	module UI
		class DisplayTextAction < Entity::Action
			def initialize(entity, text, speed = 50)
				super(entity)
				@text = text.split(//)
				@left = @speed = speed
			end

			def enter
				entity.renderer.new_line
			end

			def update(delta)
				while delta > @left
					delta -= @left
					@left = @speed
					entity.renderer << @text.shift
					break if done?
				end
				@left -= delta
			end

			def done?
				@text.empty?
			end
		end

		class ScrollTextAction < Entity::Action
			def initialize(entity, speed = 100)
				super(entity)
				@speed = speed
				@current = 0
			end

			def update(delta)
				@current += delta
				if @current > @speed
					@done = true
				else
					entity.renderer.displace = @current / @speed.to_f
				end
			end

			def done?
				@done
			end
		end

		class InputAction < Entity::Action
			def initialize(entity, keys, &block)
				super(entity)
				@keys = keys
				@callback = block if block_given?
			end

			def enter
				entity.renderer.wait = true
			end

			def exit
				entity.renderer.wait = false
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

		class Window < GameObject
			attr_reader :x, :y, :z
			attr_reader :width, :height

			def initialize(x, y, w, h, z, border)
				super()
				@x, @y, @z = x, y, z
				@width, @height = w, h
				BorderRenderer.new(self, border)
			end

			def done?
				true
			end

			def press(id)
			end
		end

		class TextWindow < Window
			attr_reader :renderer, :charset

			def initialize(s, z, charset, border)
				super(0, Utils::SCREEN_SIZE[1] - 6 * charset.char_height, Utils::SCREEN_SIZE[0], 6 * charset.char_height, z, border)
				@charset = charset
				@controller = Entity::ActionController.new(self)

				paragraphs = s.split("\r").map { |p| p.split("\n") }
				paragraphs.reject &:empty?

				paragraphs.each_with_index do |p, j|
					s = p.size - 1
					p.each_with_index do |l, i|
						@controller << DisplayTextAction.new(self, l)
						unless i == 0 or i == s
							@controller << InputAction.new(self, [:A, :B]) << ScrollTextAction.new(self)
						end
					end
					@controller << (InputAction.new(self, [:A, :B]) { renderer.reset }) unless j == paragraphs.size - 1
				end

				@renderer = TextRenderer.new(self, 
					self.x + 3 * charset.char_width / 2, 
					self.y + 3 * charset.char_height / 2,
					2 * charset.char_height)
			end

			def done?
				@controller.empty?
			end

			def press(id)
				e = @controller.active
				e.accept id if e and e.respond_to? :accept
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

