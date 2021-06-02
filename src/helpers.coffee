import * as _ from "@dashkite/joy"
import chalk from "chalk"

class TaskError extends Error
  constructor: (@message, @task, @original) ->
    super()

format = ({task, duration, timestamp}) ->
  task = "task [#{task}]" if task?
  duration = "#{duration.toFixed 2}ms" if duration?
  {task, duration, timestamp}

colorize = ({task, duration, timestamp}) ->
  task = chalk.green task if task?
  duration = chalk.magenta duration if duration?
  {task, duration, timestamp}

_log = (text) -> console.error "[genie]", text

log =
  info: (message, context = {}) ->
    template = _.template message
    _log "#{template colorize format context}"
  error: (message, context = {}) ->
    template = _.template message
    _log chalk.red "#{template format context}"

report = _.generic
  name: "report"
  description: "Report errors to the console."
  default: (error) -> log.error error.toString()

_.generic report, _.isError, (error) ->
  log.error error.message
  if process.env.DEBUG?.match /\bgenie\b/
    console.error error

_.generic report, (_.isType TaskError), ({original, message, task}) ->
  report original
  log.error message, {task}

export {
  TaskError
  log
  format
  report
}
