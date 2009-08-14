#!/opt/local/bin/ruby

require 'rubygems'
require 'serialport'

$sp = SerialPort.new( "/dev/tty.usbserial-A70063S8", 115200, 8, 1, SerialPort::NONE )

while a = gets
	i = a.strip.to_i
	
	$sp.putc i
end