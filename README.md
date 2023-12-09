# Genie

A CoffeeScript-based task runner. (And nothing else.)

See [Masonry][] for functions that read, write, and process files.

[Masonry]://github.com/dashkite/masonry#README.md


## Installation

```
npm i genie
```

## Usage

```
npx genie [<task-name>...]
```

If no arguments are given, the defined tasks are listed.

Task definitions should be placed in the `tasks` directory.

## Defining Tasks

Define tasks in your `tasks/index.coffee` file. Note that Genie will also check `tasks/index.js` for task definitions. We like CoffeeScript, so you'll see that in examples below, but as long as Node can `require` the files referenced in index, Genie can run the defined functions. 

For example, here's a simple _hello, world_ task.

```coffeescript
import * as Genie from "@dashkite/genie"

Genie.define "hello-world", -> console.log "Hello, World"
```

Run the task like this:

```
npx genie hello-world
```

## Dependent Tasks

You can define tasks that a given task depends on by simply listing them in an array or a whitespace-separated string.

```coffeescript
Genie.define "build", "clean", ->
  # build task goes here
```

## Parallel Tasks

You can append a ‘&’ to any task you define and it will run in parallel with the other tasks.

```coffeescript
Genie.define "server", "html& css& js&", ->
  server "build", fallback: "index.html"
```

## Before And After Tasks

You can add before and after tasks to other tasks as well, which is nice for augment pre-packaged tasks.

```coffeescript
import * as Genie from "@dashkite/genie"

Genie.after "build", "images"
```

## Event-Driven Tasks

You can define multiple task handlers via `on` in place of `define`:

```coffeescriot
import * as Genie from "@dashkite/genie"

Genie.on "hello-world", -> console.log "Hello, World"
```

The advantage of using `on` instead of `define` and `before` or `after` is that each handler is independent of the others. The disadvantage is that handlers run in the order they're declared, so you can't guarantee one handler will run before another. Using `on` provides an event-driven interface to tasks.

**Important:** Using `define` will overrite any handlers registered with `on`. You should avoid using `define` and `on` together for the same task name.

## Parameterized Tasks

You can pass parameters to tasks in two ways. First, you can pass them via the environment.

```coffeescript
targets='array' npx genie test
```

Second, you can define parameterized task names. Components of a task name are separated by `:`. If the task name is not found, the last component will be treated as an argument instead. This process continues until either a task name is found or there are no components remaining.

For example, suppose we have a task `foo` that takes a parameter. We can reference `foo:bar` and the string *bar* will be passed into the task.

So if our task definition is:

```coffeescript
Genie.define "foo", (name) -> console.log "foo", name
```

and we run it as:

```coffeescript
npx genie foo:bar
```

it will print *foo bar*.

## Configuration

You may define a `genie.yaml` file in the directory from which you will run `genie` and that configuration will be available to tasks via the `get` function. This is useful for dynamically configuring pre-packaged tasks.

## Presets

Development dependencies whose names (regardless of their scope) begin with `genie-` will be preloaded by Genie. Such modules are expected to export a (possibly asynchronous) task definition function taking the Genie instance that called them. They can then use this instance to define new tasks.

Preset loading may be surpressed for a given preset by using the `-x` option.

## API

### after

*after task-name, task-to-run*

Define a task to run after another task.

### before

*before task-name, task-to-run*

Define a task to run before another task.

### configure

*configure configuration*

Set the Genie configuration. The `genie` command reads this from the `genie.yaml` file.

### define

*define name, dependencies, fn*

Define a task with the given name and dependencies using the given function.

### get

*get property → value*

Read a property from the configuration.

### list

*list*

List all the tasks that have been defined.

### lookup

*lookup name*

Find a given task.

### on

*define name, dependencies, fn*

Define a task handler with the given name and dependencies using the given function. Similar to `define`, but allows multiple handlers to run for the same task.

### run

*run name*

Runs the given task name.
