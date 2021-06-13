# including this just in case it starts working somehow
require "source-map-support/register"
require "module"
  .prototype
  .options =
    transpile:
      configFile: false
      presets: [[
        require "@babel/preset-env"
        targets: node: "current"
      ]]

require "coffeescript/register"

import Path from "path"
import YAML from "js-yaml"
import * as _ from "@dashkite/joy"
import {isFile, read} from "panda-quill"
import dayjs from "dayjs"
import chalk from "chalk"
import * as genie from "./index"
import { log, report} from "./helpers"

tasks = process.argv[2..]

do ->
  log.info "Run at {{timestamp}}",
    timestamp: dayjs().format "YYYY-MM-DD hh:mm:ss A ZZ"

  if await isFile "genie.yaml"
    genie.configure YAML.load await read "genie.yaml"

  try
    if await isFile "tasks/index.coffee"
      require Path.resolve "tasks/index.coffee"

    if await isFile "tasks/index.js"
      require Path.resolve "tasks/index.js"

      if tasks.length == 0
        console.log chalk.green _.join "\n", do genie.list
      else
        await genie.run tasks
  catch error
    report error
    process.exit 1
