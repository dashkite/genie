# reportCycle = ( cycle ) ->
#   do ({ fancy } = {}) ->
#     fancy = cycle.join " -> "
#     log.warn "Cycle detected: #{ fancy }"

# __decycle = do ( visited = {}) ->
#   ( name, dependencies, path ) ->
#     do ({ _dependencies, key, task, cycle } = {}) ->
#       name = strip name
#       _dependencies = dependencies.map strip
#       key = [ name, _dependencies... ].join " "
#       unless visited[ key ]?
#         visited[ key ] = true
#         path ?= [ name ]
#         if name in _dependencies
#           reportCycle [ path..., name ]
#           index = _dependencies.indexOf name
#           dependencies.splice index, 1
#           true
#         else if _dependencies.length > 0
#           cycle = false
#           for dependency in _dependencies
#             task = lookup dependency
#             if task?
#               cycle = __decycle name, task.dependencies, [ path..., task.name ]
#               cycle = ( __decycle task.name, task.dependencies ) || cycle
#             else
#               log.warn "genie:
#                 missing dependency: #{ dependency }"
#           cycle
#         else false
#       else true

# _decycle = ( task ) -> 
#   __decycle task, ( lookup strip task ).dependencies

# decycle = ( tasks ) -> 
#   tasks
#     .map _decycle
#     .some ( result ) -> result  