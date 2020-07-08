import {isString, isArray, isFunction, isDefined} from "panda-parchment"
import Method from "panda-generics"
import {red, green, magenta} from "colors/safe"

tasks = {}
lookup = (name) -> tasks[name]

define = Method.create
  name: "define"
  description: "Defines a Genie task."

Method.define define, isString, isArray, isFunction,
  (name, dependencies, action) ->
    tasks[name] = {dependencies, action}

Method.define define, isString, isString, isFunction,
  (name, dependencies, action) ->
    define name, (dependencies.split /\s+/), action

Method.define define, isString, isDefined,
  (name, dependencies) -> define name, dependencies, ->

Method.define define, isString, isFunction,
  (name, action) -> define name, [], action

run = (name = "default", visited = []) ->

  flag = name[-1..]
  if flag == "&"
    background = true
    name = name[0..-2]

  unless name in visited

    console.error "[genie] Starting #{green name} ..."

    visited.push name

    if (task = lookup name)?
      {dependencies, action} = task

      for dependency in dependencies
        await run dependency, visited

      start = process.hrtime.bigint()

      finish = ->
        finish = process.hrtime.bigint()
        duration = Number((finish - start)/BigInt(1e6))
        console.error "[genie] Finished #{green name} in #{magenta duration}ms."

      result = action()

      if background
        if result?.then?
          result.then finish
        else
          finish()
      else
        await result
        finish()

    else
      console.error red "[P9K] task #{green name} not found."

export {define, run}
