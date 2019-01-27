require 'open4'
    
class PhantomRunner

  PHANTOM_LAUNCH_COMMAND = '/home/deploy/node_modules/phantomjs2/lib/phantom/bin/phantomjs --disk-cache=true --load-images=false /home/deploy/apps/abc_dent/current/prerendering/prerender.js 8888 http://localhost:80'

  def initialize

    @current_pid = false
    run_phantom
  
  end

  def run_phantom

    status =
      Open4::popen4(PHANTOM_LAUNCH_COMMAND) do |pid, stdin, stdout, stderr|

        stdin.close

        @current_pid = pid

        puts "pid        : #{ pid }"
        puts "stdout     : #{ stdout.read.strip }"
        puts "stderr     : #{ stderr.read.strip }"
      end

      puts "status     : #{ status.inspect }"
      puts "exitstatus : #{ status.exitstatus }"

      if status
        restart
      end

    
  end

  def teminate_current_phantom
    if @current_pid

      Open3.popen3("pkill -TERM -P #{@current_pid}") do |i, o, e, t|

        i.close
        o.gets
        e.gets

        if t.value.success?

          restart

        end

      end


    end
  end

  def restart

    run_phantom  

  end


end


PhantomRunner.new




