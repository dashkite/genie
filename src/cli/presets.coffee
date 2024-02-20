import FSX from "#helpers/fsx"
import * as Genie from "#genie"

Name =

  descope: ( qname ) ->
    if qname.startsWith "@"
      ( qname.split "/" )[ 1 ]
    else qname

  preset: ( qname ) ->
    if Name.isPreset qname
      ( Name.descope qname )[6..]
    else name

  isPreset: ( qname ) -> 
    Name
      .descope qname
      .startsWith "genie-"
  
Presets =

  valid: ( exclude, qname ) ->
    ( Name.isPreset qname ) && !(( Name.preset qname ) in exclude )

  import: ( exclude ) ->
    { devDependencies } = JSON.parse await FSX.read "package.json"
    for qname in Object.keys devDependencies
      if Presets.valid exclude, qname
        exports = require require.resolve qname, 
          paths: [ "./node_modules" ]
        await exports?.default? Genie

export default Presets