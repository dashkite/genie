import "source-map-support/register"
import YAML from "js-yaml"

import dayjs from "dayjs"

import * as Genie from "./index"
import { round, log, print } from "./helpers/log"
import { isFile, read } from "./helpers/file"
import { getTaskFile } from "./helpers/import"
import { loadGenieModules } from "./helpers/load"
import { Benchmark } from "./helpers/benchmark"

tasks = process.argv[2..]

do ->

  log.info "Loading tasks ..."

  Benchmark.start "loading"

  if await isFile "genie.yaml"
    Genie.configure YAML.load await read "genie.yaml"

  await loadGenieModules Genie

  if ( path = await getTaskFile())?
    require path

  Benchmark.finish "loading"
  
  log.info "Finished loading tasks in 
    #{ round Benchmark.duration "loading" }ms."
  
  try

    if tasks.length == 0
      print Genie.list().join "\n"
    else
      await Genie.run tasks

  catch error
    log.error error
    process.exit 1
