import { lookup } from "../task"

Specifier =

  make: ( specifier ) ->
    Specifier.parse specifier
  
  parse: ( specifier ) ->
    priority = 0
    background = false
    optional = false
    once = true
    consume = false
    symbols = [ specifier... ]
    loop
      path = symbols.join ""
      current = symbols.pop()
      switch current
        when "+" then priority++
        when "-" then priority--
        when "?" then optional = true
        when "!" then once = false
        when "&" then background = true
        else
          # valid references must end with a \w
          if path.endsWith ":*"
            path = path[...-2]
            consume = true
          if /\w$/.test path
            modifiers = { priority, background, optional, once, consume }
            return { path, modifiers }
          else
            throw new Error "invalid specifier: 
              [ #{ specifier } ] at '#{ current }'"
  
  destructure: ( path ) ->
    names = path.split ":"
    args = []
    while names.length > 0
      if ( task = lookup names.join ":" )?
        return { path, task, args }
      else
        args.unshift names.pop()
    undefined

export { Specifier }