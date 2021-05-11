import coffee from "coffeescript"
import Path from "path"
import * as _ from "@dashkite/joy"
import {isFile, read} from "panda-quill"
import dayjs from "dayjs"
import {green, red} from "colors/safe"
import {run, list} from "./index"

load = (path) ->
  # import tasks
  coffee.run (await read path),
    filename: path
    bare: true
    inlineMap: true
    transpile:
      configFile: false
      presets: [[
        "@babel/preset-env"
        targets: node: "current"
      ]]

tasks = process.argv[2..]
path = Path.join process.cwd(), "tasks", "index.coffee"

do ->
  console.error "[genie] Run at",
    green dayjs().format "YYYY-MM-DD hh:mm:ss A ZZ"
  try
    if await isFile path
      await load path
      if tasks.length == 0
        console.log green _.join "\n", do list
      else
        await run tasks
    else
      console.error red "[genie] unable to find a tasks/index.{js,coffee} file"
      process.exit 1
  catch error
    console.error red "[genie] #{error.stack}"
