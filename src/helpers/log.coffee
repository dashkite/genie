import chalk from "chalk"
import dayjs from "dayjs"
import log from "@dashkite/kaiko"

frame = ( list, message ) ->
  result = ""
  for item in list
    result += "[ #{ item } ] "
  result = ( chalk.magenta.dim result ) + message
  
colors =
  info: "green"
  warn: "yellow"
  error: "red"
  fatal: "bgRed"
  debug: "blue"

log.observe ( event ) ->
  color = colors[ event.level ] ? "green"
  message = frame [ "genie" ], event.data
  console.log chalk[ color ] message

print = ( value ) -> console.log chalk.green value

round = do ( formatter = undefined ) -> 
  ( n ) ->
    formatter ?= Intl.NumberFormat "en",
      minimumFractionDigits: 2
      maximumFractionDigits: 2
    formatter.format n

export { log, print, round }