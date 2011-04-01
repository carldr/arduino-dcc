#!/opt/local/bin/ruby

require 'rubygems'
require 'serialport'

#  tty.usbserial-A70063S8 == !mega

$sp = SerialPort.new( "/dev/tty.usbserial-A70063S8", 115200, 8, 1, SerialPort::NONE )

puts "s <loco_num> <speed>'"
puts "0 - 126 = Anti-Clockwise"
puts "0 - -126 = Clockwise"
puts "-127/127 = Emergency Stop"
puts
puts "f <loco_num> <func_no> <0|1>'"
puts
puts "p <point_num> <straight|curved> : Points default to straight"
puts

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

def do_point( point, cmd )
	straight = 1 if cmd =~ /^s/
	straight = 0 if cmd =~ /^c/
	if not [ 0, 1 ].include? straight
		puts "p <point_num> <straight|curved>"
		return nil
	end

	[ "p"[0], point, straight ]
end

def put_data( data )
	print "Output : "
	data.each do |d|
		print "0x%02x " % d
		$sp.putc d
	end

	puts
end

=begin
while 1
	puts "0"
	put_data( do_point( 3, 0 ) )
	sleep 5

	puts "1"
	put_data( do_point( 3, 1 ) )
	sleep 5
end
=end

print "> "
while a = gets
	deets = a.strip.split( / / )
	command = deets.shift
	deets.map!{ |d| d =~ /^-?[0-9]+$/ ? d.to_i : d }

	data = nil

	begin
		data = case command
		when "s"
			do_speed( *deets )
		when "f"
			do_function( *deets )
		when "p"
			do_point( *deets )
		end
	rescue
		puts $!.to_s
	end

	put_data( data ) if data

	print "> "
end