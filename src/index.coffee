import * as _ from "@dashkite/joy"
import chalk from "chalk"

configuration = {}
configure = (c) -> configuration = c
get = (key) -> configuration[key]

tasks = {}

hooks =
  before: {}
  after: {}

lookup = (name, args = []) ->
  names = _.split ":", name
  if names.some _.isEmpty
    throw new Error "invalid task name: #{name}"
  while names.length > 0
    _name = _.join ":", names
    if (task = tasks[_name])?
      before = hooks.before[ _name ]
      after = hooks.after[ _name ]
      return {name, task..., args, before, after}
    args = [
      _.pop names
      args...
    ]
  undefined

list = -> _.keys tasks

define = _.generic
  name: "define"
  description: "Defines a Genie task."

_.generic define, _.isString, _.isArray, _.isFunction,
  (name, dependencies, action) ->
    tasks[name] = {dependencies, action}

_.generic define, _.isString, _.isString, _.isFunction,
  (name, dependencies, action) ->
    define name, (dependencies.split /\s+/), action

_.generic define, _.isString, _.isDefined,
  (name, dependencies) -> define name, dependencies, ->

_.generic define, _.isString, _.isFunction,
  (name, action) -> define name, [], action

before = _.generic
  name: "before"
  description: "Defines a 'before' Genie task hook."

_.generic before, _.isString, _.isArray,
  (name, dependencies) ->
    hooks.before[ name ] = _.cat (hooks.before[ name ] ? []), dependencies

_.generic define, _.isString, _.isString,
  (name, dependencies) ->
    before name, _.split /\s+/, dependencies

after = _.generic
  name: "after"
  description: "Defines a 'after' Genie task hook."

_.generic after, _.isString, _.isArray,
  (name, dependencies) ->
    hooks.after[ name ] = _.cat (hooks.after[ name ] ? []), dependencies

_.generic after, _.isString, _.isString,
  (name, dependencies) ->
    after name, _.split /\s+/, dependencies

run = _.generic
  name: "run"
  description: "Run a Genie task or tasks."

_.generic run, _.isArray, _.isArray, (tasks, visited) ->
  for task in tasks
    await run task, visited

_.generic run, _.isArray, (tasks) -> run tasks, []

_.generic run, _.isObject, _.isArray,
  ({name, action, args, dependencies, before, after}, visited) ->
    await run before, visited if before?
    await run dependencies, visited
    duration = await _.benchmark -> _.apply action, args
    await run after, visited if after?
    console.error "[genie] Finished #{chalk.green name}
      in #{chalk.magenta duration}ms."

_.generic run, _.isString, _.isArray, (name, visited) ->

  if _.endsWith "&", name
    background = true
    name = name[0..-2]

  unless name in visited
    console.error "[genie] Starting #{chalk.green name} ..."
    visited.push name
    if (task = lookup name)?
      try
        if background then run task, visited else await run task, visited
      catch error
        console.error chalk.red "[genie] Error running task [#{name}]"
        console.error error
    else
      console.error chalk.red "[genie] task #{chalk.green name} not found."

_.generic run, _.isString, (task) -> run task, []

export {
  lookup
  define
  before
  after
  run
  list
  configure
  get
}
