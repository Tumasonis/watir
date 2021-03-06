module WatirSpec
  class RemoteServer
    attr_reader :server

    def start(port = 4444)
      require 'selenium/server'

      @server ||= Selenium::Server.new(jar,
                                       port: Selenium::WebDriver::PortProber.above(port),
                                       log: !!$DEBUG,
                                       background: true,
                                       timeout: 60)
      @server.start
      at_exit { @server.stop }
    end

    private

    def jar
      if ENV['LOCAL_SELENIUM']
        local = File.expand_path('../selenium/buck-out/gen/java/server/src/org/openqa/grid/selenium/selenium.jar')
      end

      if File.exist?(ENV['REMOTE_SERVER_BINARY'] || '')
        ENV['REMOTE_SERVER_BINARY']
      elsif ENV['LOCAL_SELENIUM'] && File.exists?(local)
        local
      elsif !Dir.glob('*selenium*.jar').empty?
        Dir.glob('*selenium*.jar').first
      else
        Selenium::Server.download :latest
      end
    rescue SocketError
      # not connected to internet
      raise Watir::Exception::Error, "unable to find or download selenium-server-standalone jar"
    end
  end
end