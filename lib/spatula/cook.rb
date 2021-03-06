module Spatula
  # TODO: Set REMOTE_CHEF_PATH using value for file_cache_path
  REMOTE_CHEF_PATH = "/tmp/chef-solo" # Where to find upstream cookbooks

  class Cook < SshCommand
    def initialize(server, node, port=nil, login=nil, identity=nil)
      super(server, port, login, identity)
      @node = node
    end

    def run
      Dir["**/*.rb"].each do |recipe|
        ok = sh "ruby -c #{recipe} >/dev/null 2>&1"
        raise "Syntax error in #{recipe}" if not ok
      end

      if @server =~ /^local$/i
        sh chef_cmd
      else
        sh "rsync -rlP --rsh=\"ssh #{ssh_opts}\" --delete --exclude '.*' ./ #@server:#{REMOTE_CHEF_PATH}"
        ssh "cd #{REMOTE_CHEF_PATH}; #{chef_cmd}"
      end
    end

    private
      def chef_cmd
        "sudo chef-solo -c config/solo.rb -j config/#@node.json"
      end
  end
end
