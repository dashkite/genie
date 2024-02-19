import { generic } from "@dashkite/joy/generic"
import { Task } from "./task"

Groups =

  make: ( context ) ->
    specifiers = context.specifiers.toSorted ( a, b ) -> 
      b.modifiers.priority - a.modifiers.priority
    groups = []
    current = undefined
    for specifier in specifiers
      if specifier.modifiers.background
        if current?.type == "parallel"
          current.specifiers.push specifier
        else
          current = { type: "parallel", specifiers: [ specifier ]}
          groups.push current
      else
        if current?.type == "sequential"
          current.specifiers.push specifier
        else
          current = { type: "sequential", specifiers: [ specifier ]}
          groups.push current
    { context..., groups }
  
  run: ({ context..., groups }) ->
    for group in groups
      await Group.run { context..., group }
    context

Group =

  isSequential: ({ group }) -> group.type == "sequential"
  
  isParallel: ({ group }) -> group.type == "parallel"

Group.run = do ({ run } = {}) ->
    
  run = generic name: "Group.run"

  generic run,
    Group.isSequential,
    ( context ) ->
      for specifier in context.group.specifiers
        await Task.run { context..., specifier }
      
  generic run,
    Group.isParallel,
    ( context ) ->
      for specifier in context.group.specifier
        Task.run { context..., specifier }

  run
  
export { Groups, Group }

