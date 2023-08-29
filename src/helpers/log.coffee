import chalk from "chalk"
import dayjs from "dayjs"

DEBUG = do ->
  if ( debug = process.env.DEBUG )?
    ( debug.split /\s+/ )
      .map ( name ) -> name.toLowerCase()
      .includes "genie"

splat = ( f ) ->
  ( value ) ->
    f if Array.isArray value 
      value
        .map splat f
        .join " " 
    else if value.stack?
      if DEBUG
        if value.source?
          "#{ value.message }\n#{ value.source.stack }"
        else
          value.stack
      else
        value.message
    else value
    
Colors =
  info: splat ( value ) -> chalk.green value
  warn: splat ( value ) -> chalk.yellow value
  error: splat ( value ) -> chalk.red value
  debug: splat ( value ) -> chalk.blue value
  highlight: splat ( value ) -> chalk.magenta value

print = ( value ) -> console.log Colors.info value

# TODO use Temporal API
makeTimestamp = ->
  dayjs().format "YYYY-MM-DD hh:mm:ss.SSS A"

class Logger

  @make: ( scopes ) -> 
    Object.assign ( new Logger ), { scopes }

  # TODO make this a getter
  @label: ( instance ) ->
    instance
      .scopes
      .map ( scope ) -> "[ #{ scope } ]"
      .join ""

  scope: ( name ) ->
    Logger.make [ @scopes..., name ]

  log: ( level, args... ) ->
    console[ level ] ( Colors.highlight makeTimestamp() ),
      ( Colors[ level ] Logger.label @ ),
      ( Colors[ level ] args )

  error: ( args... ) -> @log "error", args...

  warn: ( args... ) -> @log "warn", args...

  info: ( args... ) -> @log "info", args...

  debug: ( args... ) -> @log "debug", args...

log = Logger.make [ "genie" ]

round = do ( formatter = undefined ) -> 
  ( n ) ->
    formatter ?= Intl.NumberFormat "en",
      minimumFractionDigits: 2
      maximumFractionDigits: 2
    formatter.format n

export { log, print, round }