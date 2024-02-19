import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import { lookup, make } from "./task"

after = generic
  name: "after"
  description: "Defines a 'after' Genie task hook."

generic after, Type.isString, Type.isArray,
  ( name, dependencies)  ->
    if ( task = lookup name )?
      task.after = [ task.after..., dependencies... ]
      task
    else
      make name, after: dependencies

generic after, Type.isString, Type.isString,
  ( name, dependencies ) ->
    after name, dependencies.split /\s+/

export { after }