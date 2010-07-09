#!/opt/local/bin/ruby

require 'rubygems'
require 'serialport'

#  tty.usbserial-A70063S8 == !mega

$sp = SerialPort.new( "/dev/tty.usbserial-A70063S8", 115200, 8, 1, SerialPort::NONE )

puts "Use 's loco speed'"
puts "0 - 126 = Anti-Clockwise"
puts "0 - -126 = Clockwise"
puts "-127/127 = Emergency Stop"
puts
puts "Use 'f loco func_no 1' or 'f loco func_no 0'"

def do_speed( loco, speed )
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

print "> "
while a = gets
	deets = a.strip.split( / / )
	command = deets.shift
	deets.map!{ |d| d.to_i }
	
	data = case command
	when "s"
		do_speed( *deets )
	when "f"
		do_function( *deets )
	end
	
	put_data( data )

	print "> "
end