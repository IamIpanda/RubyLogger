require 'colored'

module IamI
  LOGGER_LEVELS = {
      debug: 0,
      info: 1,
      warning: 2,
      warn: 2,
      error: 3,
      fatal: 4,
      silent: 100
  }

  class Logger
    attr_reader :name
    attr_accessor :level
    attr_accessor :destination
    attr_accessor :colors
    attr_reader :triggers
    attr_accessor :stack_count
    attr_accessor :time_format
    attr_reader :recent_message_queue
    attr_accessor :recent_message_count
    attr_accessor :trigger_any_message
    attr_accessor :colored_message_model
    attr_accessor :uncolored_message_model

    def initialize(name = nil)
      @name = name
      @level = :info
      @destination = $stderr
      @colors = {
          debug: :magenta,
          info: :cyan,
          warn: :yellow,
          error: :red,
          fatal: :red,
          time: :blue,
          stack: :green
      }
      @triggers = {}
      @stack_count = 3
      @time_format = '%Y-%m-%d %H:%M:%S.%L'
      @colored_message_model = '[%s][%14s][%s] %s'
      @uncolored_message_model = '[%s][%5s][%s] %s'
      @trigger_any_message = false
      @file_streams = {}
      @recent_message_queue = []
      @recent_message_count = 50
      this = self
      name_symbol = @name.to_sym
      $__register_logger_reference_main__.instance_eval do
        define_method name_symbol, proc { this }
      end
    end

    def log(level, msg, *tag)
      if should_log? level
        colored_message = format level, msg
        uncolored_message = format level, msg, false
        destinations = get_destination level
        destinations = [destinations] unless destinations.is_a? Array
        destinations.each do |destination|
          io = get_io destination
          io.puts is_destination_file?(destination) ? uncolored_message : colored_message
        end
        @recent_message_queue.push uncolored_message
        @recent_message_queue.shift if @recent_message_queue.length > @recent_message_count
      end
      trigger(msg, uncolored_message, *tag) if @trigger_any_message or should_log? level
    end

    def format(level, msg, color = true)
      time = get_time_str
      level = get_level_str level
      stack = get_stack_str
      if color
        dye time, @colors[:time]
        dye level, @colors[level.to_sym] || :red
        dye stack, @colors[:stack]
        sprintf @colored_message_model, time, level, stack, msg
      else
        sprintf @uncolored_message_model, time, level, stack, msg
      end
    end

    def trigger(msg, line, *tag)
      return if @triggers.nil?
      @triggers.values.each do |trigger|
        trigger.call msg, line, *tag if trigger.is_a? Proc
      end
    end

    def is_destination_file?(obj)
      obj.is_a? String
    end

    def get_io(obj)
      return obj if obj.is_a? IO
      return unless obj.is_a? String
      @file_streams[obj] = File.open obj, 'a' if @file_streams[obj] == nil
      @file_streams[obj]
    end

    def should_log?(level)
      IamI::LOGGER_LEVELS[level] >= IamI::LOGGER_LEVELS[@level]
    end

    def get_destination(level)
      if @destination.is_a? Hash
        @destination[level,to_sym] || $stderr
      else
        @destination
      end
    end

    def get_time_str
      Time.now.strftime @time_format
    end

    def get_stack_str
      caller[@stack_count].sub Dir.pwd + '/', ''
    end

    def get_level_str(level)
      level.to_s
    end

    def dye(str, color)
      return if color == nil
      str.replace str.__send__ color.to_sym
    end

    alias classic_method_missing method_missing
    def method_missing(name, *args, &block)
      if IamI::LOGGER_LEVELS.has_key? name
        log name, *args, &block
      else
        classic_method_missing name, *args, &block
      end
    end

    def register_trigger(name = nil, &block)
      name = block.__id__.to_s if name.nil?
      @triggers[name] = block
      name
    end

    def unregister_trigger(key)
      @triggers.delete key
    end
  end
end

$__register_logger_reference_main__ = self
require File.dirname(__FILE__) + '/sinatra-middleware.rb'