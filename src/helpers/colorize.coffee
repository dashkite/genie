import * as Scan from "@dashkite/scan"
import chalk from "chalk"

parse = ( text ) ->
  state = "start"
  current = type: "text", value: ""
  tokens = []
  for c in text
    switch state
      when "start"
        switch c
          when "["
            tokens.push current
            current = type: "block", value: c
            state = "block"
          else
            current.value += c
      when "block"
        switch c
          when "]"
            current.value += c
            tokens.push current
            current = type: "text", value: ""
            state = "start"
          else
            current.value += c
  switch state
    # we never got a closing ], so this is just text
    when "block"
      tokens[ tokens.length - 1 ].value += current.value
    # save that last token ...
    when "start"
      tokens.push current if current.value.length > 0
  tokens

finish = ( tokens ) ->
  result = ""
  for token in tokens
    switch token.type
      when "text"
        result += token.value
      when "block"
        result += chalk.blue.bold token.value
  result

colorize = ( text ) -> finish parse text    

export default colorize