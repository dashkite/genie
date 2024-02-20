import "source-map-support/register"
import { program } from "commander"
import Module from "#helpers/module"
import command from "./command"

program
  .version Module.version
  .enablePositionalOptions()
  .description "Task Manager"
  .option "-x, --exclude <presets...>", 
    "Exclude a preset from auto-loaded"
  .option "-c, --halt", "Halt if a cycle is detected", false
  .option "-q, --quiet", "Supress normal logging
    (useful when piping to stdout)"
  .option "-d, --debug", "Provide debug output"
  .argument "[tasks...]", "List of tasks to run"
  .action command

program.parseAsync()