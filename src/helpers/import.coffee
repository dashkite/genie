import Path from "node:path"
import Coffee from "coffeescript"
import { log } from "./log"
import {
  isFile
  isNewer
  read
  write
  glob
} from "./file"

compile = ( source, target ) ->
  write target,
    Coffee.compile ( await read source ),
      bare: true
      inlineMap: true
      filename: source
      transpile:
        filename: source
        presets: [
          [ require "@babel/preset-env" ]
        ]
        plugins: [
          [ require "babel-plugin-autocomplete-index" ]          
        ]
        targets: node: "current"

getTarget = ( root, path ) ->
  directory = Path.dirname path
  extension = Path.extname path
  basename = Path.basename path, extension
  Path.join root, directory, "#{ basename }.js"

compileAll = ->
  for source from await glob "tasks/**/*.coffee"
    target = getTarget ".genie", source
    try
      if await isNewer source, target
        await compile source, target
    catch error
      console.log error

relative = Path.join "tasks", "index.js"

getTaskFile = ->
  await compileAll()
  target = Path.join ".genie", relative   
  if await isFile target 
    Path.resolve target 
  else if await isFile relative
    Path.resolve relative

export {
  getTaskFile
}