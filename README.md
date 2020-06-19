# Genie

A simple CoffeeScript task runner. (And nothing else.)

See [Brick](../brick/README.md) for functions that read, write, and process files.

## Installation

```
npm i genie
```

## Usage

```
npx genie [<task-name>...]
```

If no arguments are given, the `default` task name is used.

Task definitions should be placed in the `tasks` directory.

## Defining Tasks

Define tasks in your `tasks/index.coffee` file.

For example, here's a simple _hello, world_ task.

```coffeescript
import {define} from "@dashkite/genie"

define "hello-world", -> console.log "Hello, World"
```

Run the task like this:

```
npx genie hello-world
```

## Dependent Tasks

You can define tasks that a given task depends on by simply listing them in an array or a whitespace-separated string.

```coffeescript
define "build", "clean", ->
  # build task goes here
```

## Parallel Tasks

You can append a ‘&’ to any task you define and it will run in parallel with the other tasks.

```coffeescript
define "server", "html& css& js&", ->
  server "build", fallback: "index.html"
```

## API

### define name, dependencies, fn

Define a task with the given name and dependencies using the given function.

### run name

Runs the given task name.

### 