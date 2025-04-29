import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import { lookup } from "./task"
import { define } from "./define"

event = generic
  name: "event"
  description: "Defines a Genie task handler."

generic event, 
  Type.isString,
  Type.isArray, 
  Type.isFunction,
  ( name, dependencies, action ) ->
    if !( task = lookup name )?
      define name, dependencies, action
    else
      task.dependencies = [ task.dependencies..., dependencies... ]
      task.actions = [ task.actions..., action ]
      task

generic event,
  Type.isString,
  Type.isString,
  Type.isFunction,
  ( name, dependencies, action ) ->
    event name, ( dependencies.split /\s+/ ), action

generic event, 
  Type.isString, 
  Type.isDefined,
  ( name, dependencies ) ->
    event name, dependencies, ->

generic event,
  Type.isString, 
  Type.isFunction,
  ( name, action ) ->
    event name, [], action

export { event as on }