import * as _ from "@dashkite/joy"

import { log, round } from "./helpers/log"
import { Benchmark } from "./helpers/benchmark"

configuration = {}
configure = ( c ) -> configuration = c
get = ( key ) -> configuration[ key ]

tasks = {}

hooks =
  before: {}
  after: {}

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

list = -> ( _.keys tasks ).sort()

_on = _.generic
  name: "on"
  description: "Defines a Genie task handler."

_.generic _on, _.isString, _.isArray, _.isFunction,
  ( name, dependencies, action ) ->
    if ( task = tasks[ name ])?
      task.actions.push action
    else
      tasks[name] = { dependencies, actions: [ action ] }

_.generic _on, _.isString, _.isString, _.isFunction,
  ( name, dependencies, action ) ->
    _on name, ( dependencies.split /\s+/ ), action

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

run = _.generic
  name: "run"
  description: "Run a Genie task or tasks."

_.generic run, _.isArray, _.isArray, _.isArray, ( tasks, args, visited ) ->
  for task in tasks
    await run task, args, visited

_.generic run, _.isArray, ( tasks ) -> run tasks, [], []

_.generic run, _.isObject, _.isArray,
  ({ name, actions, args, dependencies, before, after }, visited ) ->

    # attempt to run explicit and implicit dependencies
    try
      await ( run before, args, visited ) if before?
      await run dependencies, args, visited
    catch error
      # don't run dependent if dependencies failed
      throw new Error "Dependency failed for #{ name }: #{ error }"

    # attempt to run the main tasks
    try
      for action in actions
        log.info "Starting #{ name } ..."
        Benchmark.start name
        await _.apply action, args
        Benchmark.finish name
        log.info "Finished #{ name } in #{ round Benchmark.duration name }ms."
    catch error
      # don't run after if the subject task failed
      throw new Error "Error running #{ task }: #{ error }"

    try
      await ( run after, args, visited ) if after?
    catch error
      throw new Error "Dependent #{ name } failed"

_.generic run, _.isString, _.isArray, _.isArray, ( name, args, visited ) ->

  if _.endsWith "&", name
    background = true
    name = name[0..-2]

  if _.endsWith ":*", name
    if args.length > 0
      name = name.replace "*", args.join ":"
    else
      name = name[0..-3]

  unless name in visited
    visited.push name
    if (task = lookup name)?
      if background then run task, visited else await run task, visited
    else
      log.error "task #{ name } not found."

_.generic run, _.isString, (task) ->
  try
    await run task, [], []
  catch error
    log.error error

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
}
