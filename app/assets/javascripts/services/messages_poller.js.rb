module Services
  class MessagesPoller

    def initialize(rate, &block)
      @proc = block
      @rate = rate
      @running = false
    end

    def start
      @running = true
      @interval = %x{
        setInterval(function(){ #{ @proc.call } }, #{@rate})
      }
    end

    def stop
      %x{
        clearInterval(#{@interval})
      }
      @running = false
    end

  end
end