import assert from "assert"
import * as p from "path"
import {print, test} from "amen"
import {start, glob, read, tr, write} from "@dashkite/brick"
import {define, run} from "../src"
import * as q from "panda-quill"

source = p.resolve "test", "files"
build = p.resolve "test", "build"

log = (context) -> console.log {context} ; context

do ->

  print await test "Genie", [

    test "define task", ->

      define "clean", -> q.rmr build

      define "poem", [ "clean" ], start [
        glob "*.txt", source
        read
        tr (path, content) -> content + "whose fleece was white as snow."
        write build
      ]

      await run "poem"

      assert.equal "Mary had a little lamb,\nwhose fleece was white as snow.",
        await q.read p.join build, "poem.txt"

  ]
