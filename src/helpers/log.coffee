import * as Type from "@dashkite/joy/type"
import chalk from "chalk"
import dayjs from "dayjs"
import log from "@dashkite/kaiko"
import colorize from "./colorize"

frame = ( list, message ) ->
  result = ""
  for item in list
    result += "[ #{ item } ] "
  result = ( chalk.magenta.dim result ) + colorize message
  
colors =
  info: "green"
  warn: "yellow"
  error: "red"
  fatal: "bgRed"
  debug: "blue"

log.observe ( event ) ->
  if event.data?
    color = colors[ event.level ] ? "green"
    message = frame [ "genie" ], event.data.message ? event.data
    console.log chalk[ color ] message
    if event.level == "debug" && event.data.stack?
      console.log chalk[ color ] event.data.stack

print = ( value ) -> console.log chalk.green value

round = do ( formatter = undefined ) -> 
  ( n ) ->
    formatter ?= Intl.NumberFormat "en",
      minimumFractionDigits: 2
      maximumFractionDigits: 2
    formatter.format n

Format =

  duration: ( duration ) ->
    if duration < 1000
      units = "ms"
    else
      duration /= 1000
      units = "s"
    chalk.magenta "#{ round duration }#{ units }."

  timestamp: ( t ) ->
    chalk.magenta t.format "ddd MMM DD h:mm:ss A"
  
  now: ->
    Format.timestamp dayjs()

export { log, print, round, Format }