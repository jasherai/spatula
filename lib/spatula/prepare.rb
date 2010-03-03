# Prepare :server: for chef solo to run on it
module Spatula
  class Prepare
    Spatula.register("prepare", self)

    def self.run(*args)
      new(*args).run
    end

    def initialize(server, port=22)
      @server = server
      @port   = port
    end

    def ssh command
      sh %Q|ssh -t -p #@port #@server "#{command.gsub('"', '\\"')}"|
    end

    def run
      ssh "sudo apt-get update"
      ssh "sudo aptitude -y install ruby irb ri libopenssl-ruby1.8 libshadow-ruby1.8 ruby1.8-dev gcc g++ rsync"
      ssh "curl -L 'http://rubyforge.org/frs/download.php/69365/rubygems-1.3.6.tgz' | tar xvzf -"
      ssh "cd rubygems* && sudo ruby setup.rb --no-ri --no-rdoc"
      ssh "sudo ln -sfv /usr/bin/gem1.8 /usr/bin/gem"

      ssh "sudo gem install rdoc chef ohai --no-ri --no-rdoc --source http://gems.opscode.com --source http://gems.rubyforge.org"
    end

    private
      def sh(command)
        system command
      end
  end
end