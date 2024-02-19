import { Specifier } from "./specifier"

Context =

  make: ( specifiers ) ->
    visited: []
    promised: []
    args: []
    specifiers:
      for specifier in specifiers
        Specifier.make specifier

  from: ( aspect, { command, context }) ->
    { visited, promised, args } = context
    args = [ args..., command.args... ]
    specifiers = Context.make command.task[ aspect ]
    { specifiers..., visited, promised, args }
  
export { Context }
