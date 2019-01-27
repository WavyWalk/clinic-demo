require 'socket'               # Get sockets from stdlib
require 'open4'
require 'open3'
    

class PhantomRunner

  PHANTOM_LAUNCH_COMMAND = '/home/deploy/node_modules/phantomjs2/lib/phantom/bin/phantomjs --disk-cache=true --load-images=false /home/deploy/apps/abc_dent/current/prerendering/prerender.js 8888 http://localhost:80'

  def initialize
    @status = '500'
    @current_pid = false
  end

  def start
    @thread = Thread.new do
      run_phantom
    end
    @status = '200'
  end

  def run_phantom

    status =
      Open4::popen4(self.class::PHANTOM_LAUNCH_COMMAND) do |pid, stdin, stdout, stderr|

        stdin.close

        @current_pid = pid

        #puts "pid        : #{ pid }"
        #puts "stdout     : #{ stdout.read.strip }"
        #puts "stderr     : #{ stderr.read.strip }"
      end

    #puts "status     : #{ status.inspect }"
    puts "exitstatus : #{ status.exitstatus }"

    if status
      restart
    end

    
  end

  def restart_phantom
    @status = '500'
    if @current_pid

      Open3.popen3("pkill -TERM -P #{@current_pid}") do |i, o, e, t|

        i.close
        # o.gets
        # e.gets

        if t.value.success?

          restart

        end

      end


    end
  end

  def restart
    
    sleep 2
    start  

  end


end


@phantom_runner = PhantomRunner.new

@phantom_runner.start

server = TCPServer.open(2999)

loop {

  client = server.accept
  message = client.gets.chomp

  if message == 'status'
    client.puts @phantom_runner.status
  end

  if message == 'start'
    @phantom_runner.start
    client puts 'ok'
  elsif message == 'restart'
    @phantom_runner.restart_phantom
    client.puts 'ok'
  elsif message == 'exit'
    client.puts 'ok'
    break
  end
  
  client.close
}    

