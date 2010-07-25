#!/opt/local/bin/ruby

require "rubygems"
require "eventmachine"
require "serialport"

$sp = SerialPort.new "/dev/cu.usbserial-A70063S8", 115200

def do_speed( loco, speed )
	if speed > -10 and speed < 10
		speed = 0
	end

	if speed < 0 && speed > -127
		speed = 129 - speed

	elsif speed > 0 && speed < 127
		speed = 1 + speed

	elsif speed == 0
		speed = 0

	else
		speed = 1
	end

	[ "s"[0], loco, speed ]
end

def do_function( loco, func, status )
	[ "f"[0], loco, func, status ]
end

def put_data( data )
	print "Output : "
	data.each do |d|
		print "0x%02x " % d
		$sp.putc d
	end

	puts
end


class SpeedServer < EventMachine::Connection
	include EventMachine::Protocols::LineText2
	
	def post_init
		puts "Got a connection ..."
		
		send_data "0\r\n"
	end
	
	def receive_line( line )
		# 0 - 126 = Anti-Clockwise
		# 0 - -126 = Clockwise
		# -127/127 = Emergency Stop

		puts "Input : " + line
		
		deets = line.strip.split( / / )
		command = deets.shift
		deets.map!{ |d| d.to_i }

		data = case command
		when "s"
			do_speed( *deets )
		when "f"
			do_function( *deets )
		end

		put_data( data )
	end
	
	def unbind
		puts "Lost a connection ..."
	end
end

EventMachine.run {
	EventMachine::start_server "0.0.0.0", 7531, SpeedServer
}