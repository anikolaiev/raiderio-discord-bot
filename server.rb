require 'socket'
server = TCPSocket.new 'localhost', 8080

while line = server.gets
  puts line
end

server.close
