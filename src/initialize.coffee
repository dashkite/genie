import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import { lookup, make } from "./task"

initialize = generic
  name: "initialize"
  description: "Defines a Genie task's initialization."

generic initialize, Type.isString, Type.isArray,
  ( name, dependencies)  ->
    if ( task = lookup name )?
      task.initialize = [ task.initialize..., dependencies... ]
      task
    else
      make name, initialize: dependencies

generic initialize, Type.isString, Type.isString,
  ( name, dependencies ) ->
    initialize name, dependencies.split /\s+/

export { initialize }