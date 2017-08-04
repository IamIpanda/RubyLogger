module IamI
  class Logger
    attr_accessor :connections
    def before_function
      this = self
      Proc.new do
        this.connections = [] if this.connections == nil
        content_type 'text/event-stream'
        stream :keep_open do |output_stream|
          this.connections << output_stream
          log_hook = this.register_trigger do |message, line|
            output_stream << "data: #{line}\r\nid: #{this.name}"
          end
          output_stream.callback do
            this.connections.delete output_stream
            ygopro_images_manager_logger.unregister_trigger log_hook
          end
        end
      end
    end
  end
end