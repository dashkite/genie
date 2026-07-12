# Genie

*A CoffeeScript-based task runner. (And nothing else.)*

[![Hippocratic License HL3-CORE](https://img.shields.io/static/v1?label=Hippocratic%20License&message=HL3-CORE&labelColor=5e2751&color=bc8c3d)](https://firstdonoharm.dev/version/3/0/core.html)

See [Masonry](https://github.com/dashkite/masonry#README.md) for functions that read, write, and process files.

## Features

- Pure CoffeeScript-based task runner
- Support for dependent and parallel tasks
- Event-driven task execution with `before` and `after` hooks
- Parameterized task definitions via environment variables or task names
- Dynamic configuration via `genie.yaml`

## Installation

```sh
pnpm install genie
```

## Usage

### Command-Line Usage

List defined tasks by running genie without arguments:

```sh
npx genie
```

Run one or more tasks by specifying their names:

```sh
npx genie build server
```

### Programmatic Usage

Task definitions should be placed in the `tasks/index.coffee` or `tasks/index.js` file.

## Other Resources

- [Reference Documentation](docs/reference.md)
- [Usage Guides and Recipes](docs/recipes.md)
- [Technical Notes](docs/technical-notes.md)
- [Testing](docs/testing.md)
