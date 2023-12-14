import "source-map-support/register"
import Path from "node:path"
import FS from "node:fs"
import chalk from "chalk"
import YAML from "js-yaml"

import dayjs from "dayjs"

import * as Genie from "./index"
import { round, log, print } from "./helpers/log"
import { isFile, read } from "./helpers/file"
import { getTaskFile } from "./helpers/import"
import { loadGenieModules } from "./helpers/load"
import { Benchmark } from "./helpers/benchmark"
import { program } from "commander"

run = ( tasks, { quiet, exclude, halt }) ->

  unless quiet
    log.level = "info"

  log.info "run at " +
    chalk.magenta dayjs().format "ddd MMM DD h:mm:ss A"

  exclude ?= []

  log.info "Loading tasks ..."

  Benchmark.start "loading"

  if await isFile "genie.yaml"
    Genie.configure YAML.load await read "genie.yaml"

  await loadGenieModules Genie, exclude

  if ( path = await getTaskFile())?
    require path

  Benchmark.finish "loading"

  # TODO have logger automatically detect duration
  #      once we switch to log objects instead of text
  log.info "Finished loading tasks" + 
    chalk.magenta " in #{ round Benchmark.duration "loading" }ms."
  
  try

    if tasks.length == 0
      print Genie.list().join "\n"
    else
      cycles = Genie.decycle tasks
      if halt && cycles
        process.exit 1
      await Genie.run tasks

  catch error
    log.error error
    process.exit 1


program
  .version do ({ path, json, pkg } = {}) ->
    path = Path.join __dirname, "..", "..", "package.json"
    json = FS.readFileSync path, "utf8"
    pkg = JSON.parse json
    pkg.version
  .enablePositionalOptions()
  .description "Task Manager"
  .option "-x, --exclude <presets...>", 
    "Exclude a preset from auto-loaded"
  .option "-c, --halt", "Halt if a cycle is detected", false
  .option "-q, --quiet", "Supress normal logging
    (useful when piping to stdout)"
  .argument "[tasks...]", "List of tasks to run"
  .action run

program.parseAsync()