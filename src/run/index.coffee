import { generic } from "@dashkite/joy/generic"
import * as Type from "@dashkite/joy/type"
import { Tasks } from "./task"
import { Context } from "./context"

run = generic
  name: "run"
  description: "Run a Genie task or tasks."

generic run, 
  Type.isArray, 
  ( specifiers ) -> 
    Tasks.run Context.make specifiers

generic run, 
  Type.isString, 
  ( specifiers ) -> 
    run specifiers.split /\s+/

export { run }