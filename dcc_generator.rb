#!/opt/local/bin/ruby

require 'rubygems'
require 'serialport'

#  tty.usbserial-A70063S8 == !mega

$sp = SerialPort.new( "/dev/tty.usbserial-A70063S8", 115200, 8, 1, SerialPort::NONE )

puts "Use 'loco:speed'"
puts "0 - 126 = Anti-Clockwise"
puts "0 - -126 = Clockwise"
puts "-127/127 = Emergency Stop"

while a = gets
	loco, speed = a.strip.split( /:/ ).map{ |s| s.to_i }
	
	if speed < 0 && speed > -127
		speed = 129 + speed

	elsif speed > 0 && speed < 127
		speed = 1 + speed

	elsif speed == 0
		speed = 0

	else
		speed = 1
	end

  puts "Output : #{loco},#{speed}"

	$sp.putc loco
	$sp.putc speed
end