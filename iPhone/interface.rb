#!/opt/local/bin/ruby

require "rubygems"
require "eventmachine"
require "serialport"

class SpeedServer < EventMachine::Connection
	include EventMachine::Protocols::LineText2
	
	def post_init
		puts "Got a connection ..."
		
		@sp = SerialPort.new "/dev/cu.usbserial-A70063S8", 115200
		
		send_data "0\r\n"
	end
	
	def receive_line( line )
		print "Input : " + line
		
		i = line.strip.to_i
	
		if i < 0
			i-=1
		end

		if i > 0
			i+=1
		end

		if i < 0
			i = 128 + 128 - ( i.abs )
		else
			i = 128 - i
		end

		puts ", Output : " + i.to_s

		@sp.putc -i
	end
	
	def unbind
		puts "Lost a connection ..."
	end
end

EventMachine.run {
	EventMachine::start_server "0.0.0.0", 7531, SpeedServer
}