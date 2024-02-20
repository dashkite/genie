import { Format, log } from "#helpers/log"
import { Benchmark } from "#helpers/benchmark"

import Configuration from "./configuration"
import Presets from "./presets"
import Local from "./local"

initialize = ({ quiet, debug, exclude, halt }) ->
  
  exclude ?= []

  if debug
    log.level = "debug"
  else if !quiet
    log.level = "info"

  log.info "run at " + Format.now()

  log.info "Loading tasks ..."

  Benchmark.start "loading"

  await do Configuration.load
  await Presets.import exclude
  await do Local.import

  Benchmark.finish "loading"

  log.info "Finished loading tasks in " + 
    Format.duration Benchmark.duration "loading"

export default initialize