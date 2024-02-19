import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import { lookup, make } from "./task"

before = generic
  name: "before"
  description: "Defines a 'before' Genie task hook."

generic before, Type.isString, Type.isArray,
  ( name, dependencies)  ->
    if ( task = lookup name )?
      task.before = [ task.before..., dependencies... ]
      task
    else
      make name, before: dependencies

generic before, Type.isString, Type.isString,
  ( name, dependencies ) ->
    before name, dependencies.split /\s+/

export { before }