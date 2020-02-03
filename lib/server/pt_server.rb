# frozen_string_literal: true

require 'socket'

class PTServer
  def initialize(params)
    @server = TCPServer.new(params[:host], params[:port])
  end

  def handle(handler)
    loop do
      session = @server.accept
      #Thread.start(@server.accept) do |session|
        handler.call(session)
      #end
    end
  end
end
