import { read } from "./file"

loadGenieModules = ( Genie ) ->
  { devDependencies } = JSON.parse await read "./package.json"
  await Promise.all do ->
    for qname in Object.keys devDependencies
      name = do ->
        if qname.startsWith "@"
          ( qname.split "/" )[ 1 ]
        else qname
      if name.startsWith "genie-"
        exports = require require.resolve qname, 
          paths: [ "./node_modules" ]
        exports.default? Genie

export { loadGenieModules }

