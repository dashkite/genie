import Path from "node:path"
import FS from "node:fs/promises"
import Coffee from "coffeescript"
import * as swc from "@swc/core"
import { log } from "#helpers/log"
import FSX from "#helpers/fsx"

Target = 

  js: Path.join ".genie", "tasks", "index.js"

  join: ( root, path ) ->
    directory = Path.dirname path
    extension = Path.extname path
    basename = Path.basename path, extension
    Path.join root, directory, "#{ basename }.js"

Local =

  js: Path.join "tasks", "index.js"

  coffee: Path.join "tasks", "index.coffee"

  compile: ( source, target ) ->
    js = Coffee.compile ( await read source ),
      bare: true
      inlineMap: true
      filename: "/#{ source }"
    [ version ] = process.versions.node.split "."
    { code } = await swc.transform js,
      inputSourceMap: true  
      sourceMaps: "inline" 
      jsc:
        parser:
          syntax: "ecmascript"
      module:
        type: "commonjs"
      env:
        targets:
          node: version
    write target, code

  build: ->
    targets = []
    for source from await FSX.glob "tasks/**/*.coffee"
      target = Target.join ".genie", source
      targets.push target
      if await FSX.isNewer source, target
        await Local.compile source, target
    # remove targets that have no correspodning source
    for target from await FSX.glob ".genie/tasks/**/*.js"
      await FS.rm target unless target in targets

  import: ->
    if await FSX.isFile Local.js
      require Path.resolve Local.js
    else if await FSX.isFile Local.coffee
      await do Local.build
      require Path.resolve Target.js
      
export default Local