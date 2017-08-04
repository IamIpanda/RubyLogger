# IamI::Logger
IamI::Logger 是某自用的 Ruby Logger 库。
## 使用
    IamI::Logger.new('global_logger')
    global_logger.info('Hello, world!')
    
## Log 等级
参见 `IamI::LOGGER_LEVELS`

分别为 `:debug`, `:info`, `:warning` / `:warn`, `error`, `:fatal`, `:silent`
## IamI::Logger 参数
名称|类型|说明
---|---|---
name|Readonly String|此Logger的名称。注册后，可以在任何地方使用。
level|Symbol|低于此等级的Log会被忽略
destination|[stream or IO or Filename]|指定此Logger的去向
colors|{Level Symbol => Color Symbol}|指定日志的颜色
triggers|{name => Trigger Proc}|触发器群
stack_count|Fixnum|指定堆栈消息要向前推断多少级。默认为3。
time_format|String|时间的输出形式
recent_message_count|Fixnum|Logger 为你保存最近的多少条消息
recent_message_queue|[]|Logger 最近发送的消息。
trigger_any_message|Bool|配置低于level的消息是否触发触发器
colored_message_model|String|指定输出消息的形式。
uncolored_message_model|String|指定输出消息的形式。


## IamI::Logger 函数
### log(level, msg, *tags)
以给定等级`level`输出消息`msg`。`*tags` 会被传递给触发器。

### debug/info/warn/error/fatal(msg, *tags)
以此等级转发 `log`

### register_trigger(name, proc)
注册触发器。每次 `log` 时均将 `uncolored_message` 传给 `proc`。

### unregister_trigger(name)
注销触发器。

### before_function
需要 `Sinatra`。
返回一个能够用于 SSE 的 `Proc`。

## 范例
自己用的 Logger 写这么多范例干什么！

**So Lazy Can't Move**