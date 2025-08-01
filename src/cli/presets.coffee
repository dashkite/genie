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
    { dependencies, devDependencies } = JSON.parse await FSX.read "package.json"
    qnames = Object.keys devDependencies
    if ( presets = Genie.get "presets" )?
      qnames = [ qnames..., presets... ]
    Promise.all do ->
      for qname in qnames when Presets.valid exclude, qname
        exports = require require.resolve qname, 
          paths: [ "./node_modules" ]
        exports?.default? Genie

export default Presets