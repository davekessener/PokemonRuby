require 'gosu'


class Main
	def initialize
		$root_dir = File.expand_path(File.dirname(__FILE__))
		require_pattern = File.join($root_dir, '**/*.rb')
		@failed = []
		
		Dir.glob(require_pattern).each do |file|
			f = file.gsub("#{$root_dir}/", '')
		
			next if f == 'main.rb'
			
			begin
				require_relative f
			rescue
				@failed << f
			end
		end

		15.times do
			resolve_dependencies
			break if @failed.empty?
		end

		if not @failed.empty?
			puts "Failed to include files #{@failed.join(', ')}!"
			@failed.each { |f| require_relative f }
		else
			Pokemon::Logger::log("Executing in directory '#{$root_dir}'")

			scene = Pokemon::OverworldScene.new
			$window = Pokemon::Window.new(scene)

			begin
				$window.show
			rescue
				Pokemon::Logger::print_all
				raise
			end
		end
	end

	private

	def resolve_dependencies
		tmp, @failed = @failed, []
		tmp.each do |file|
			begin
				require_relative file
			rescue
				@failed << file
			end
		end
	end
end

Main.new
