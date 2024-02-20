import Path from "node:path"
import FS from "node:fs/promises"
import * as Glob from "fast-glob"

mtime = ( path ) ->
  try
    stat = await FS.stat path
    stat.mtimeMs
  catch
    0

FSX =

  glob: ( patterns, cwd = "." ) ->
    Glob.glob patterns, { cwd }

  read: ( path ) -> FS.readFile path, "utf8"

  write: ( path, output ) ->
    await FS.mkdir ( Path.dirname path ), recursive: true
    FS.writeFile path, output

  isFile: ( path ) ->
    try
      stat = await FS.stat path
      stat.isFile()
    catch
      false

  isNewer: ( source, target ) ->
    ( await mtime source ) > ( await mtime target )

export default FSX
