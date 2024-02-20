import Path from "node:path"
import FS from "node:fs"

Module = do ({ path, json } = {}) ->
  path = Path.join __dirname, "..", "..", "..", "package.json"
  json = FS.readFileSync path, "utf8"
  JSON.parse json

export { Module }
export default Module