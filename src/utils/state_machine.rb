require 'set'

module Pokemon
module Utils
	module StateMachine
		def self.included(base)
			base.extend ClassMethods
		end

		def method_missing(name, *args, &block)
			if self.class._sm_is_event? name
				_sm_transition name
			else
				super
			end
		end

		def respond_to_missing?(name)
			self.class._sm_is_event? name
		end

		def _sm_transition(event)
			@_sm_machines.each do |name, state|
				@_sm_machines[name] = self.class._sm_transition(self, name, state, event)
			end
		end

		class Machine
			def initialize(init)
				@init = init
				@states = {}
				@events = Set.new
			end

			def state(id, &block)
				@states[id] = (st = State.new(id))
				st.instance_eval(&block) if block_given?
				@events.merge(st.events_impl)
			end

			def transition_impl(o, state, event)
				r = state
				st = @states[state]
				if st.events_impl.include? event
					if (trans = st.receive_impl(event, o))
						st.exit_impl(o)
						r = trans.call
						@states[r].enter_impl(o)
					end
				end

				r
			end

			def events_impl
				@events
			end

			def startup_impl(o)
				@states[@init].enter_impl(o)
				@init
			end
		end

		class State
			attr_reader :id

			def initialize(id)
				@id = id
				@trans = {}
			end

			def transition(event, cb_id = nil, **args, &block)
				trans = {target: args[:to], callback: {id: cb_id, callback: block}, condition: args[:if]}
				if (t = @trans[event])
					t << trans
				else
					@trans[event] = [trans]
				end
			end

			def on_enter(cb_id = nil, &block)
				@on_enter = {id: cb_id, callback: block}
			end

			def on_exit(cb_id = nil, &block)
				@on_exit = {id: cb_id, callback: block}
			end

			def enter_impl(o)
				exec_on(o, @on_enter) if @on_enter
			end

			def exit_impl(o)
				exec_on(o, @on_exit) if @on_exit
			end

			def events_impl
				@trans.keys.to_set
			end

			def receive_impl(id, o)
				t = @trans[id].find do |e|
					c = e[:condition]
					c.nil? or (c.respond_to?(:call) ? o.instance_eval(&c) : o.send(c))
				end
				lambda do
					exec_on(o, t[:callback])
					t[:target]
				end if t
			end

			private

			def exec_on(o, cb)
				if (f = cb[:id])
					o.send f
				elsif (f = cb[:callback])
					o.instance_eval(&f)
				end
			end
		end

		module ClassMethods
			def new(*args, &block)
				super.tap do |o|
					o.instance_variable_set(:@_sm_machines, @_sm_machines.map do |name, m|
						[name, m.startup_impl(o)]
					end.to_h) if @_sm_machines
				end
			end

			def state_machine(name, init, &block)
				@_sm_machines ||= {}
				@_sm_events ||= Set.new

				@_sm_machines[name] = (m = Machine.new(init))
				m.instance_eval(&block) if block_given?
				@_sm_events.merge(m.events_impl)
			end

			def _sm_is_event?(id)
				@_sm_events.include? id
			end

			def _sm_transition(o, name, state, event)
				@_sm_machines[name].transition_impl(o, state, event)
			end
		end
	end
end
end

