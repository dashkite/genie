import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import { Groups } from "./group"
import { Specifier } from "./specifier"
import { Context } from "./context"
import { Format, log } from "#helpers/log"
import { Benchmark } from "#helpers/benchmark"

Tasks =

  run: ( context ) ->
    if context.specifiers.length > 0
      Groups.run Groups.make context
    else
      context

Task =

  prepare: ({ context..., specifier }) ->
    { path, modifiers } = specifier
    if ( command = Specifier.destructure path )?
      if context.visited[ path ]? && modifiers.once
        if ( promise = context.promised[ path ])?
          promise
      else
        if modifiers.consume
          command.args.push context.args...
        command
    else if modifiers.optional
      context
    else
      throw new Error "task not found: #{ path }"

  run: ( context ) ->
    do ({ command } = {}) ->
      command = Task.prepare context
      if !command?
        context
      else if Type.isPromise command
        log.info "Waiting on #{ command.path } ..."
        command
      else
        context.visited[ command.path ] = true
        context.promised[ command.path ] = do ->
          log.info "Starting #{ command.path } ..."
          Benchmark.start command.path
          frame = { context, command }
          await Tasks.run Context.from "before", frame
          await Tasks.run Context.from "dependencies", frame
          await Promise.all do ->
            for action in command.task.actions
              action command.args...
          Benchmark.finish command.path
          log.info "Finished #{ command.path } in " +
            Format.duration Benchmark.duration command.path
          await Tasks.run Context.from "after", frame
          delete context.promised[ command.path ]
          context
   
export { Tasks, Task }


     