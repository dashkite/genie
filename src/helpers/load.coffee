import { read } from "./file"

loadGenieModules = ( Genie, exclude ) ->
  { devDependencies } = JSON.parse await read "./package.json"
  for qname in Object.keys devDependencies
    name = if qname.startsWith "@"
      ( qname.split "/" )[ 1 ]
    else qname
    if name.startsWith "genie-"
      unless ( name[6..] in exclude )
        exports = require require.resolve qname, 
          paths: [ "./node_modules" ]
        await exports?.default? Genie

export { loadGenieModules }

