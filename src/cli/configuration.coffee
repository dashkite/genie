import YAML from "js-yaml"
import * as Genie from "#genie"
import FSX from "#helpers/fsx"

Configuration =

  load: ->
    if await FSX.isFile "genie.yaml"
      Genie.write YAML.load await FSX.read "genie.yaml"
        
export default Configuration