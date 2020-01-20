require "socket"

params = {
  host: 'localhost',
  port: 3333
}

tcp_server = TCPServer.new(params[:host], params[:port])

while session = tcp_server.accept
  request_start_time = Time.now

  request = session.gets
  headers = {}
  handled = false

  while header_string = session.gets do
    break if header_string == "\r\n"
    key, value = header_string.split(': ')
    http_key = 'HTTP_' + key.sub('-','_').upcase
    value.sub!("\r\n", '')
    headers[http_key] = value
  end

  verb, path, http_version = request.split(' ')

  # serve static
  static_extensions = %w(css js ico)
  if verb == 'GET'
    path_parts = path.split('.')
    current_ext = path_parts.last
    if path == '/favicon.ico' || static_extensions.include?(current_ext)
      puts "Serve static file: #{path}"
      file_path = "./public#{path}"
      # TODO : Dynamic content type
      content_type = 'image/x-icon'
      response_code = 200
      handled = true
    end
  end

  if !handled
    # serve dynamic rouiting request
    if verb == 'GET' && path == '/'
      file_path = './data/index.html'
      content_type = 'text/html'
      response_code = 200
    elsif verb == 'GET' && path.start_with?('/page/')
      file_name = path.sub '/page/', ''
      file_path = "./data/#{file_name}.html"
      content_type = 'text/html'
      response_code = 200
    else
      file_path = './data/error-404.html'
      content_type = 'text/html'
      response_code = 404
    end
  end

  if File.exist? file_path
    file = File.read(file_path)
  else
    file = "File #{path} not found"
    content_type = 'text/html'
    response_code = 404
  end

  response = "#{http_version} #{response_code}\r\nContent-Type: #{content_type}\r\nContent-Size: #{file.length}\r\n\r\n#{file}"

  session.puts response
  session.close

  request_duration_ms = ((Time.now.to_f - request_start_time.to_f) * 1000).round(4)
  puts "#{Time.now}, #{verb}, #{path}, #{response_code}, #{request_duration_ms} ms"
end
