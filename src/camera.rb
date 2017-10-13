module Pokemon
	module Camera
		class Container < GameObject
			attr_reader :control
			attr_accessor :following

			def initialize
				super(0, 0, 0, 0)
				@control = Control.new(self)
			end

			def x
				@following ? @following.x + @following.width / 2 : super
			end

			def y
				@following ? @following.y + @following.height / 2 : super
			end
		end

		class Control < Component
		end
	end
end

