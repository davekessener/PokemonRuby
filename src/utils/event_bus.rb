module Pokemon
module Utils
	class EventBus
		def initialize
			@clients = {}
		end

		def register(id, client)
			@clients[id] = client
		end

		def transmit(id, message)
			@clients[id].receive(message) if @clients
		end

		def broadcast(message)
			@clients.each { |c| c.receive(message) }
		end

		def knows?(id)
			@clients.keys.include? id
		end
	end
end
end

