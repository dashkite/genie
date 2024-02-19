import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import { make } from "./task"

define = generic
  name: "define"
  description: "Defines a Genie task."

generic define,
  Type.isString, 
  Type.isArray, 
  Type.isFunction,
  ( name, dependencies, action ) ->
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
    make name, { dependencies }

generic define, 
  Type.isString, 
  Type.isFunction,
  ( name, action ) -> 
    make name, actions: [ action ]

export { define }