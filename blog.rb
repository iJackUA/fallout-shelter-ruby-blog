require "socket"

params = {
  host: 'localhost',
  port: 3333
}

tcp_server = TCPServer.new(params[:host], params[:port])

while session = tcp_server.accept
  request_start_time = Time.now
  request = session.gets
  puts request
  verb, path, http_version = request.split(' ')

  if verb == 'GET' && path == '/'
    file_path = './data/index.html'
    response_code = 200
  elsif verb == 'GET' && path.start_with?('/page/')
    file_name = path.sub '/page/', ''
    file_path = "./data/#{file_name}.html"
    response_code = 200
  else
    file_path = './data/error-404.html'
    response_code = 404
  end

  file = File.read(file_path)

  response = "#{http_version} #{response_code}\r\nContent-Type: text/html\r\n\r\n\ #{file}"
  session.puts response
  session.close

  request_duration_ms = ((Time.now.to_f - request_start_time.to_f) * 1000).round(4)
  puts "#{Time.now}, #{verb}, #{path}, #{response_code}, #{request_duration_ms} ms"
end
