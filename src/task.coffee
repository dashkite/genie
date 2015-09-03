{go, map, collect, pull, apply, async, isString} = require "fairmont"

_tasks = {}

lookup = (name) ->
  if (_task = _tasks[name])?
    _task
  else
    console.error "Warning: Task '#{name}' is not defined."
    (async -> yield null)

task = async (name, tasks..., f) ->

  if arguments.length == 0
    yield _tasks.default()

  else if arguments.length == 1
    if (f = _tasks[name])?
      yield f()
    else
      console.error "Task '#{name}' is undefined"

  else

    if isString f
      tasks.push f
      f = undefined

    started = false
    _tasks[name] = async ->
      if !started
        started = true
        console.log "Task '#{name}' is starting…"
        for task in tasks
          g = lookup task
          yield g?()
        start = Date.now()
        yield f?()
        finish = Date.now()
        console.log "Task '#{name}' is done (#{finish-start}ms)"
        started = false

module.exports = {task}
