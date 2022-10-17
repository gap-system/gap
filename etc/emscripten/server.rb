#!/usr/bin/env ruby
# Taken from https://github.com/mame/xterm-pty/

require "webrick"

class Server < WEBrick::HTTPServer
  def service(req, res)
    super
    res["Cross-Origin-Opener-Policy"] = "same-origin"
    res["Cross-Origin-Embedder-Policy"] = "require-corp"
  end
end

Server.new(Port: 8080, DocumentRoot: ".").start

