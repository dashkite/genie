import Path from "node:path"
import FS from "node:fs/promises"
import * as Glob from "fast-glob"

isFile = ( path ) ->
  try
    stat = await FS.stat path
    stat.isFile()
  catch
    false

mtime = ( path ) ->
  try
    stat = await FS.stat path
    stat.mtimeMs
  catch
    0

isNewer = ( source, target ) ->
  ( await mtime source ) > ( await mtime target )

read = ( path ) -> FS.readFile path, "utf8"

write = ( path, output ) ->
  await FS.mkdir ( Path.dirname path ), recursive: true
  FS.writeFile path, output

glob = ( patterns ) ->
  Glob.glob patterns, cwd: "."

export {
  isFile
  mtime
  isNewer
  read
  write
  glob
}