import assert from "@dashkite/assert"
import { test, success } from "@dashkite/amen"
import print from "@dashkite/amen-console"

import FS from "fs/promises"
import Path from "path"

# module under test
import { define } from "../src/define"
import { Specifier } from "../src/run/specifier"

do ->

  print await test "Genie", [

    test "specifiers", do ->

      define "foo", ->

      [

        test "parse", [

          test "bare", ->
            specifier = Specifier.make "foo"
            assert.equal "foo", specifier.path
            assert.equal 0, specifier.modifiers?.priority

          test "with priority", ->
            specifier = Specifier.make "foo+"
            assert.equal 1, specifier.modifiers?.priority

          test "with background", ->
            specifier = Specifier.make "foo&"
            assert.equal true, specifier.modifiers?.background

          test "with once", ->
            specifier = Specifier.make "foo!"
            assert.equal false, specifier.modifiers?.once

          test "with priority and background", ->
            specifier = Specifier.make "foo&+"
            assert.equal true, specifier.modifiers?.background
            assert.equal 1, specifier.modifiers?.priority

          test "with arguments, priority, and background", ->
            specifier = Specifier.make "foo:*&+"
            assert.equal "foo", specifier.path
            assert.equal true, specifier.modifiers?.consume
            assert.equal true, specifier.modifiers?.background
            assert.equal 1, specifier.modifiers?.priority

          test "invalid specifier", ->
            assert.throws -> Specifier.make "foo:ba%&+"

        ]

        test "destructure", [

          test "with args", ->
            command = Specifier.destructure "foo:bar"
            assert.equal 0, command.task?.dependencies?.length
            assert.equal 1, command.task?.actions?.length
            assert.equal "bar", command.args?[0]

        ]


      ]




  ]

  process.exit if success then 0 else 1
