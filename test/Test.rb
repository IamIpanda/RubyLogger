require './lib/iami-logger.rb'
IamI::Logger.new 'jb'
jb.register_trigger { |msg, line, *tags| p msg, line }
jb.warn 'fuck you'