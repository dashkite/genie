import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import { lookup, make } from "./task"

define = generic
  name: "define"
  description: "Defines a Genie task."

generic define,
  Type.isString, 
  Type.isArray, 
  Type.isFunction,
  ( name, dependencies, action ) ->
    if ( task = lookup name )?
      Object.assign task, { dependencies, actions: [ action ]}
      task
    else
      make name, { dependencies, actions: [ action ] }

generic define, 
  Type.isString, 
  Type.isString, 
  Type.isFunction,
  ( name, dependencies, action ) ->
    define name, ( dependencies.split /\s+/ ), action

generic define,
  Type.isString,
  Type.isString,
  ( name, dependencies ) -> 
    define name, ( dependencies.split /\s+/ )

generic define,
  Type.isString,
  Type.isArray,
  ( name, dependencies ) -> 
    if ( task = lookup name )?
      task.dependencies = dependencies
      task
    else
      make name, { dependencies }


generic define, 
  Type.isString, 
  Type.isFunction,
  ( name, action ) -> 
    if ( task = lookup name )?
      task.actions = [ action ]
      task
    else
      make name, actions: [ action ]


export { define }