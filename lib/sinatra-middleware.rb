module IamI
  class Logger
    attr_accessor :connections

    alias connection_register_connections_initialize initialize
    def initialize(*args)
      connection_register_connections_initialize(*args)
      @connections = []
      register_trigger 'connection_trigger' do |message, line, level|
        @connections.each {|connection| connection << "data: #{line}\n\n"}
      end
    end

    def sinatra_proc
      this = self
      return Proc.new do
        content_type 'text/event-stream'
        return stream :keep_open do |output_stream|
          this.connections << output_stream
          for line in this.recent_message_queue
            output_stream << "data: #{line}\n\n"
          end
          output_stream.callback do
            this.connections.delete output_stream
          end
        end
      end
    end
  end
end