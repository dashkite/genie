import Path from "node:path"
import coffee from "coffeescript"
import { log } from "./log"
import {
  isFile
  isNewer
  read
  write
} from "./file"

compile = ( source, target ) ->
  write target,
    coffee.compile ( await read source ),
      bare: true
      inlineMap: true
      filename: source
      transpile:
        filename: source
        plugins: [
          [ require "babel-plugin-add-import-extension", {} ]
        ]
        presets: [
          [
            require "@babel/preset-env"
            targets: node: "current"
          ]
        ]

getTaskFile = ->
  try
    if await isFile "tasks/index.coffee"
      if await isNewer "tasks/index.coffee", ".genie/tasks/index.js"
        await compile "tasks/index.coffee", ".genie/tasks/index.js"
      Path.resolve ".genie/tasks/index.js"
    else if await isFile "tasks/index.js"
      Path.resolve "tasks/index.js"
  catch error
    console.log error

export {
  getTaskFile
}