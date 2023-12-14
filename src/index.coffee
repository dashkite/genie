import * as _ from "@dashkite/joy"
import { log, round } from "./helpers/log"
import { Benchmark } from "./helpers/benchmark"
import chalk from "chalk"

configuration = {}
configure = ( c ) -> configuration = c
get = ( key ) -> configuration[ key ]

tasks = {}

hooks =
  before: {}
  after: {}

running = {}

lookup = ( name, args = []) ->
  names = _.split ":", name
  if names.some _.isEmpty
    throw new Error "invalid task name: #{ name }"
  while names.length > 0
    _name = _.join ":", names
    if ( task = tasks[ _name ])?
      before = hooks.before[ name ]
      after = hooks.after[ name ]
      return { name, task..., args, before, after }
    args = [
      _.pop names
      args...
    ]
  undefined

strip = ( name ) ->

  if _.endsWith "&", name
    name[0..-2]
  else if _.endsWith ":*", name
    if args.length > 0
      name.replace "*", args.join ":"
    else
      name[0..-3]
  else name


list = -> ( _.keys tasks ).sort()

_on = _.generic
  name: "on"
  description: "Defines a Genie task handler."

_.generic _on, _.isString, _.isArray, _.isFunction,
  ( name, dependencies, action ) ->
    task = ( tasks[ name ] ?= { dependencies: [], actions: []} )
    tasks[ name ] = {
      dependencies: [ task.dependencies..., dependencies... ]
      actions: [ task.actions..., action ]
    }
    tasks[ name ]

_.generic _on, _.isString, _.isString, _.isFunction,
  ( name, dependencies, action ) ->
    _on name, ( dependencies.split /\s+/ ), action

# TODO maybe handle missing action directly?
_.generic _on, _.isString, _.isDefined,
  ( name, dependencies ) -> _on name, dependencies, ->

_.generic _on, _.isString, _.isFunction,
  ( name, action ) -> _on name, [], action


define = _.generic
  name: "define"
  description: "Defines a Genie task."

_.generic define, _.isString, _.isArray, _.isFunction,
  ( name, dependencies, action ) ->
    tasks[name] = { dependencies, actions: [ action ] }

_.generic define, _.isString, _.isString, _.isFunction,
  ( name, dependencies, action ) ->
    define name, ( dependencies.split /\s+/ ), action

_.generic define, _.isString, _.isDefined,
  ( name, dependencies ) -> define name, dependencies, ->

_.generic define, _.isString, _.isFunction,
  ( name, action ) -> define name, [], action

before = _.generic
  name: "before"
  description: "Defines a 'before' Genie task hook."

_.generic before, _.isString, _.isArray,
  ( name, dependencies ) ->
    hooks.before[ name ] = _.cat ( hooks.before[ name ] ? [] ), dependencies

_.generic before, _.isString, _.isString,
  ( name, dependencies ) ->
    before name, _.split /\s+/, dependencies

after = _.generic
  name: "after"
  description: "Defines a 'after' Genie task hook."

_.generic after, _.isString, _.isArray,
  ( name, dependencies)  ->
    hooks.after[ name ] = _.cat ( hooks.after[ name ] ? []), dependencies

_.generic after, _.isString, _.isString,
  ( name, dependencies ) ->
    after name, _.split /\s+/, dependencies

reportCycle = ( cycle ) ->
  do ({ fancy } = {}) ->
    fancy = cycle.join " -> "
    log.warn "Cycle detected: #{ fancy }"

# TODO handle missing tasks
#      lookup returns undefined when the task is missing
#      but we need to do something with that here
#      (or change lookup to throw)
__decycle = do ( visited = {}) ->
  ( name, dependencies, path ) ->
    do ({ _dependencies, key, task, cycle } = {}) ->
      name = strip name
      _dependencies = dependencies.map strip
      key = [ name, _dependencies... ].join " "
      unless visited[ key ]?
        visited[ key ] = true
        path ?= [ name ]
        if name in _dependencies
          reportCycle [ path..., name ]
          index = _dependencies.indexOf name
          dependencies.splice index, 1
          true
        else if _dependencies.length > 0
          cycle = false
          for dependency in _dependencies
            task = lookup dependency
            if task?
              cycle = __decycle name, task.dependencies, [ path..., task.name ]
              cycle = ( __decycle task.name, task.dependencies ) || cycle
            else
              console.warn "missing dependency: #{ dependency }"
          cycle
        else false
      else true

_decycle = ( start ) -> 
  if ( task = lookup strip start )?
    __decycle start, task.dependencies

decycle = ( tasks ) -> 
  tasks
    .map _decycle
    .some ( result ) -> result  

# TODO add count helper
#      to support progress bar

run = _.generic
  name: "run"
  description: "Run a Genie task or tasks."

_.generic run, _.isArray, ( tasks ) -> run tasks, [], []

_.generic run, _.isString, (task) -> run task, [], []

_.generic run, _.isArray, _.isArray, _.isArray, 
  ( tasks, args, visited ) ->
    promised = []
    for task in tasks
      if task.endsWith "&"
        promised.push run task, args, visited
      else
        await run task, args, visited
    if promised.length > 0
      await Promise.all promised
    return

_.generic run, _.isObject, _.isArray,
  ({ name, actions, args, dependencies, before, after }, visited ) ->

    if running[ name ]?
      log.info "Waiting on #{ name } ..."
      await running[ name ]
      return

    running[ name ] ?= do ->

      log.info "Starting #{ name } ..."
      Benchmark.start name

      # attempt to run explicit and implicit dependencies
      await ( run before, args, visited ) if before?
      await run dependencies, args, visited

      # attempt to run the main tasks
      try
        for action in actions
          await _.apply action, args
      catch error
        log.error "Error running #{ name }"
        throw error

      Benchmark.finish name
      # TODO have logger automatically detect duration
      #      once we switch to log objects instead of text
      duration = Benchmark.duration name
      if duration < 1000
        units = "ms"
      else
        duration /= 1000
        units = "s"
      log.info "Finished #{ name }" + 
        chalk.magenta " in #{ round duration }#{ units }."
      
      await ( run after, args, visited ) if after?
  
      # clear the promise
      running[ name ] = "completed"


_.generic run, _.isString, _.isArray, _.isArray,
  ( name, args, visited ) ->

    name = strip name

    unless name in visited
      if ( task = lookup name )?      
        await run task, visited
        visited.push name
      else
        throw new Error "task #{ name } not found."


export {
  lookup
  define
  _on as on
  before
  after
  run
  list
  configure
  get
  decycle
}
