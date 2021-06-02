import * as _ from "@dashkite/joy"
import { log, report, TaskError } from "./helpers"

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
      before = hooks.before[ name ]
      after = hooks.after[ name ]
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

_.generic before, _.isString, _.isString,
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

    # attempt to run explicit and implicit dependencies
    try
      await run before, visited if before?
      await run dependencies, visited
    catch error
      # don't run dependent if dependencies failed
      throw new TaskError "Dependency failed for {{task}}", name, error

    # attempt to run the main task
    try
      log.info "Starting {{task}} ...", task: name
      duration = await _.benchmark -> _.apply action, args
      log.info "Finished {{task}} in {{duration}}.", {task: name, duration}
    catch error
      # don't run after if the subject task failed
      throw new TaskError "Error running {{task}}", name, error

    try
      await run after, visited if after?
    catch error
      throw new TaskError "Dependent {{task}} failed", name, error

_.generic run, _.isString, _.isArray, (name, visited) ->

  if _.endsWith "&", name
    background = true
    name = name[0..-2]

  unless name in visited
    visited.push name
    if (task = lookup name)?
      if background then run task, visited else await run task, visited
    else
      log.error "task {{task}} not found.", task: name

_.generic run, _.isString, (task) ->
  try
    await run task, []
  catch error
    report error

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
