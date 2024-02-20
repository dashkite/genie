import * as Genie from "#genie"
import initialize from "./initialize"
import { log } from "#helpers/log"

command = ( tasks, options ) ->

  await initialize options

  try

    if tasks.length == 0
      print Genie.list().join "\n"
    else
      # cycles = Genie.decycle tasks
      # if halt && cycles
      #   process.exit 1
      await Genie.run tasks

  catch error
    if options.debug
      log.debug error
    else
      log.error error
    process.exit 1

export default command