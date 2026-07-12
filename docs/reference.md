# Reference Documentation

## after

$after: \text{task}, \text{target} \to \emptyset$

Define a task to run after another task.

## before

$before: \text{task}, \text{target} \to \emptyset$

Define a task to run before another task.

## configure

$configure: \text{config} \to \emptyset$

Set the Genie configuration. The `genie` command reads this from the `genie.yaml` file.

## define

$define: \text{name}, \text{dependencies}, \text{fn} \to \emptyset$

Define a task with the given name and dependencies using the given function.

## get

$get: \text{property} \to \text{value}$

Read a property from the configuration.

## list

$list: \to \emptyset$

List all the tasks that have been defined.

## lookup

$lookup: \text{name} \to \text{task}$

Find a given task.

## on

$on: \text{name}, \text{dependencies}, \text{fn} \to \emptyset$

Define a task handler with the given name and dependencies using the given function. Similar to `define`, but allows multiple handlers to run for the same task.

## run

$run: \text{name} \dashrightarrow \text{result}$

Runs the given task name.

## CLI Options

### --debug

Provide verbose debug output, including full stack traces for errors. This is critical for diagnosing test failures.

### --exclude

Exclude one or more presets from being auto-loaded.

### --halt

Halt execution immediately if a cyclic dependency is detected.

### --quiet

Suppress normal logging. This is particularly useful when piping output to stdout.

## Task Modifiers

### +

Ensure the task runs earlier in the execution cycle.

### -

Ensure the task runs later in the execution cycle.

### ?

Mark the task as optional. The task will not halt execution if it cannot be resolved.

### !

Force the task to run every time it is referenced, bypassing the default single-execution idempotency.

### &

Run the task in the background concurrently with other parallel tasks.

### :*

Consume trailing arguments dynamically, allowing dependencies to accept unparsed parameters.
