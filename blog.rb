require "socket"

params = {
  host: 'localhost',
  port: 3333
}

tcp_server = TCPServer.new(params[:host], params[:port])

while session = tcp_server.accept
  puts "#{Time.now}: TCP request started"

  file = File.read('./data.html')

  session.puts "HTTP/1.1 200\r\nContent-Type: text/html\r\n\r\n\ #{file}"
  session.close

  puts "#{Time.now}: TCP request handled"
end
