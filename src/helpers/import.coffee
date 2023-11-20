import Path from "node:path"
import Coffee from "coffeescript"
import * as swc from "@swc/core"
import { log } from "./log"
import {
  isFile
  isNewer
  read
  write
  glob
} from "./file"

current = ->
  [ major ] = process.versions.node.split "."
  major

compile = ( source, target ) ->
  js = Coffee.compile ( await read source ),
    bare: true
    inlineMap: true
    filename: "/#{ source }"
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
        node: current()
  write target, code

    # Coffee.compile ,
    #   bare: true
    #   inlineMap: true
    #   filename: source
    #   transpile:
    #     filename: source
    #     presets: [
    #       [ require "@babel/preset-env" ]
    #     ]
    #     plugins: [
    #       [ require "babel-plugin-autocomplete-index" ]          
    #     ]
    #     targets: node: "current"
    #     inputSourceMap: true

getTarget = ( root, path ) ->
  directory = Path.dirname path
  extension = Path.extname path
  basename = Path.basename path, extension
  Path.join root, directory, "#{ basename }.js"

compileAll = ->
  for source from await glob "tasks/**/*.coffee"
    target = getTarget ".genie", source
    if await isNewer source, target
      await compile source, target

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