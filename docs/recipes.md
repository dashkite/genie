# Usage Guides and Recipes

## Defining Tasks

This task demonstrates how to define a simple task in Genie.
Genie allows you to define tasks that run when their name is invoked.

```coffeescript
import * as Genie from "@dashkite/genie"

# task implementation goes here
Genie.define "hello-world", -> console.log "Hello, World"
```

1. Import the `Genie` module.
2. Call `Genie.define` with the task name and a handler function.
3. The function is executed when the task is run.

## Dependent Tasks

This task demonstrates how to define tasks that depend on other tasks.
Genie allows you to specify a list of tasks that must run before the current task.

```coffeescript
import * as Genie from "@dashkite/genie"

Genie.define "build", "clean", ->
  # build task goes here
```

1. Specify the dependent tasks as a string or array before the handler function.
2. Genie ensures the dependent tasks run before executing the current task handler.

## Parallel Tasks

This task demonstrates how to run dependencies in parallel.
Genie uses a `&` suffix on a task name to indicate it should run in parallel with others.

```coffeescript
import * as Genie from "@dashkite/genie"

Genie.define "server", "html& css& js&", ->
  # server initialization goes here
```

1. Append `&` to any dependent task name.
2. Genie executes those tasks concurrently rather than sequentially.

## Before And After Tasks

This task demonstrates how to add tasks before or after existing ones.
This is useful for augmenting pre-packaged tasks without modifying their definitions.

```coffeescript
import * as Genie from "@dashkite/genie"

Genie.after "build", "images"
```

1. Call `Genie.after` (or `Genie.before`) with the target task name and the task to add.
2. Genie automatically runs the specified task at the appropriate time relative to the target task.

## Event-Driven Tasks

This task demonstrates how to define multiple task handlers via `on`.
The advantage is that each handler is independent, providing an event-driven interface.

```coffeescript
import * as Genie from "@dashkite/genie"

Genie.on "hello-world", -> 
  # additional hello-world logic goes here
```

1. Call `Genie.on` instead of `Genie.define`.
2. Genie appends this handler to the existing handlers for the given task.

## Parameterized Tasks

This task demonstrates how to pass parameters to tasks via their name.
Genie separates task name components by `:`, treating trailing components as arguments if the exact task name is not found.

```coffeescript
import * as Genie from "@dashkite/genie"

Genie.define "foo", (name) -> 
  # process the provided name parameter goes here
```

1. Define a task that accepts parameters in its handler.
2. Invoke the task using `foo:bar` to pass `bar` as an argument.
3. You can also pass parameters via environment variables (e.g., `targets='array' npx genie test`).

## Configuration

This task demonstrates how to use configuration in tasks.
Genie reads configuration from a `genie.yaml` file, making it accessible via `Genie.get`.

```coffeescript
import * as Genie from "@dashkite/genie"

# configuration utilization goes here
configValue = Genie.get "some-property"
```

1. Create a `genie.yaml` file in the execution directory.
2. Use `Genie.get` within a task handler to read configuration values.

## Creating Presets

This task demonstrates how to create reusable presets for Genie.
Presets are modules that define common task pipelines across projects.

```coffeescript
import fs from "node:fs/promises"

export default ( Genie ) ->
  # preset task definitions go here
  Genie.define "utils:clean", ->
    await fs.rm "dist", recursive: true, force: true
```

1. Create a module whose name starts with `genie-` (e.g., `genie-coffee`).
2. Export a default function that takes a `Genie` instance.
3. Use the provided `Genie` instance to define your preset tasks.
4. When installed as a development dependency, Genie automatically preloads the module (unless suppressed with the `-x` flag).
