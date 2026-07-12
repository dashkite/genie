# Technical Notes

### Text Specifiers

Text specifiers represent strings that humans write to specify tasks and paths. 

- **Specifier** (Example: `foo:bar+`): What and how. What the human writes.
- **Path** (Example: `foo:bar`): Without modifiers. What but not how. Human writes when specifying before/after.
- **Wildcard Path** (Example: `foo:*`): Human writes this when specyfing dependencies that take args.
- **Name** (Example: `foo`): With arguments destructured, could be `foo:bar` if that was the task name.

### Object Specifiers

Object specifiers are structured representations of task components used internally by Genie.

- **Specifier** (`{ path, modifiers }`): Decoded text specifier. Necessary for sorting the groups. Defer lookup until we need to run the task.
- **Task** (`{ name, dependencies, actions }`): The thing we get out of the task dictionary.
- **Command** (`{ task, args }`): Necessary for actually invoking the task.
