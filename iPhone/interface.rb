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
		# 0 - 126 = Anti-Clockwise
		# 0 - -126 = Clockwise
		# -127/127 = Emergency Stop

		print "Input : " + line
		
		loco, speed = line.strip.split( /:/ ).map{ |s| s.to_i }
	
		if speed < 0 && speed > -127
			speed = 129 + speed

		elsif speed > 0 && speed < 127
			speed = 1 + speed

		elsif speed == 0
			speed = 0

		else
			speed = 1
		end

		puts ", Output to loco #{loco} : #{speed}"

		@sp.putc loco
		@sp.putc speed
	end
	
	def unbind
		puts "Lost a connection ..."
	end
end

EventMachine.run {
	EventMachine::start_server "0.0.0.0", 7531, SpeedServer
}