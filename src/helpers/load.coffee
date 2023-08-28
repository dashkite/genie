import { read } from "./file"

loadGenieModules = ( Genie ) ->
  { devDependencies } = JSON.parse await read "./package.json"
  for qname in Object.keys devDependencies
    if qname.startsWith "@"
      name = ( qname.split "/" )[ 1 ]
    if name.startsWith "genie-"
      exports = require require.resolve qname, paths: [ "./node_modules" ]
      exports.default? Genie

export { loadGenieModules }

