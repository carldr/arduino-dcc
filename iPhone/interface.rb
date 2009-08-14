#!/opt/local/bin/ruby

require "rubygems"
require "eventmachine"
require "serialport"

class SpeedServer < EventMachine::Connection
	include EventMachine::Protocols::LineText2
	
	def post_init
		puts "Got a connection ..."
		
		@sp = SerialPort.new "/dev/cu.usbserial-A70063S8", 115200
		
		send_data "100\r\n"
	end
	
	def receive_line( line )
		puts "*" + line + "*"
		
		i = line.strip.to_i
		
		@sp.putc i
	end
	
	def unbind
		puts "Lost a connection ..."
	end
end

EventMachine.run {
	EventMachine::start_server "0.0.0.0", 7531, SpeedServer
}