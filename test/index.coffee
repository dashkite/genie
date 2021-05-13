import assert from "assert"
import FS from "fs/promises"
import Path from "path"
import {print, test} from "amen"
import * as m from "@dashkite/masonry"
import * as $ from "../src"

source = Path.resolve "test", "files"
build = Path.resolve "test", "build"

log = (context) -> console.log {context} ; context

do ->

  print await test "Genie", [

    test "define task", ->

      $.define "clean", m.rm build

      $.define "poem", [ "clean" ], m.start [
        m.glob "*.txt", source
        m.read
        m.tr ({input}) -> input + "whose fleece was white as snow."
        m.write build
      ]

      await $.run "poem"

      assert.equal "Mary had a little lamb,\nwhose fleece was white as snow.",
        await FS.readFile (Path.join build, "poem.txt"), "utf8"

    test "define task with arguments", ->
      greeting = undefined
      $.define "greeting", (_greeting) ->
        greeting = _greeting

      await $.run "greeting:hello"
      assert.equal "hello", greeting

  ]
