require 'JSON'

module Pokemon
	module Utils
		module Enforcer
			class JSONEnforcerError < ArgumentError
			end

			class TagGenerator
				attr_reader :description

				def initialize(type, desc, opt = [], &block)
					@type = type
					@description = desc
					@optional = opt.include? :optional
					@constraints = {}

					raise "#{type} is not a class!" unless @type.is_a? Class

					instance_eval &block if block_given?
				end

				def optional?
					@optional
				end

				def constraint(desc, &block)
					@constraints[desc] = block
				end

				def constraint_positive
					constraint('positive') { |v| v > 0 }
				end

				def constraint_negative
					constraint('negative') { |v| v < 0 }
				end

				def constraint_not_empty
					constraint('not empty') { |v| not v.empty? }
				end

				def generate(data)
					raise JSONEnforcerError, "(#{@description}) should be a #{@type.to_s}, but is instead #{data.to_s}!" unless data.is_a? @type

					@constraints.each do |desc, cons|
						raise JSONEnforcerError, "constraint '#{desc}' failed on #{data.to_s}!" if not cons.call(data)
					end

					data
				end
			end

			class BooleanGenerator < TagGenerator
				def initialize(desc, &block)
					super(nil.class, desc, [], &block)
				end

				def generate(data)
					raise JSONEnforcerError, "(#{@description}) should be a Boolean, but is instead #{data.to_s}!" unless data.is_a? TrueClass or data.is_a? FalseClass

					@constraints.each do |desc, cons|
						raise JSONEnforcerError, "constraint '#{desc}' failed on #{data.to_s}!" if not cons.call(data)
					end

					data
				end
			end

			class CompoundGenerator < TagGenerator
				attr_accessor :content

				def initialize(desc, opt = [], &block)
					super(Hash, desc, opt, &block)
				end

				def strict
					@strict = true
				end

				def strict?
					@strict
				end

				def set_content(name, val)
					@content ||= {}

					raise "there is already a tag named '#{name}'!" if @content[name]

					@content[name] = val
				end

				def define_tag(name, type, desc, opt = [], &block)
					set_content(name, TagGenerator.new(type, desc, opt, &block))
				end

				def array(name, desc, opt = [], &block)
					set_content(name, ArrayGenerator.new(desc, opt, &block))
				end

				def tag(name, desc, opt = [], &block)
					set_content(name, CompoundGenerator.new(desc, opt, &block))
				end

				def bool(name, desc, opt = [], &block)
					set_content(name, BoolGenerator.new(desc, opt, &block))
				end

				{ int: Integer, double: Numeric, string: String }.each do |name, type|
					define_method name do |s, d, o = {}, &block|
						define_tag(s, type, d, o, &block)
					end
				end

				def load(fn)
					generate(JSON.parse(File.read(fn)))
				end

				def generate(data)
					super

					obj = Object.new

					data.each do |name, value|
						raise JSONEnforcerError, "encountered unplanned tag #{name} of type #{value.class.to_s}" if strict? and not @content[name]

						gen = @content[name]
						
						begin
							o = gen.generate(value)
						rescue JSONEnforcerError => e
							raise JSONEnforcerError, "(#{description}) in tag '#{name}' #{e}"
						end
						
						obj.send(:define_singleton_method, name) { o }
						obj.send(:define_singleton_method, "#{name}?") { true } if gen.optional?
					end

					@content.each do |name, gen|
						next if data[name]
						if gen.optional?
							obj.send(:define_singleton_method, "#{name}?") { false }
						else
							raise JSONEnforcerError, "tag #{name} of type #{gen.type.to_s} is missing!"
						end
					end

					obj
				end
			end

			class ArrayGenerator < TagGenerator
				attr_accessor :gen

				def initialize(desc, opt, &block)
					super(Array, desc, opt, &block)
				end

				def every_tag(type, desc = '', &block)
					@@types ||= { int: Integer, double: Numeric, string: String, array: Array, tag: Hash }
					@@generators ||= {
						int: Proc.new { |t, d, &b| TagGenerator.new(Integer, d, &b) },
						double: Proc.new { |t, d, &b| TagGenerator.new(Numeric, d, &b) },
						string: Proc.new { |t, d, &b| TagGenerator.new(String, d, &b) },
						array: Proc.new { |t, d, &b| ArrayGenerator.new(d, &b) },
						tag: Proc.new { |t, d, &b| CompoundGenerator.new(d, &b) }
					}

					@content_type = @@types[type]
					@gen = @@generators[type].call(type, desc, &block)
				end

				def generate(data)
					super

					i = 0
					data.map do |o|
						i += 1
						if @gen
							raise JSONEnforcerError, "invalid type of element ##{i}: #{o.class.to_s} instead of #{@type.to_s}!" if not o.is_a? @content_type

							begin
								@gen.generate(o)
							rescue JSONEnforcerError => e
								raise JSONEnforcerError, "(#{description}) in element ##{i} #{e}"
							end
						end
					end
				end

				def constrain_size(s)
					constraint("size of #{s}") { |v| v.size == s }
				end
			end

			def self.generate(desc, &block)
				CompoundGenerator.new(desc, &block)
			end
		end
	end
end

