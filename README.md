# DaycraftEngine

DaycraftEngine is an open-source Swift Package that provides a lightweight logic library and a macOS CLI. It is designed as an extensible foundation you can grow over time.

## Overview

DaycraftEngine ships two products:
- `DaycraftLogic`: a pure Swift library for core logic.
- `daycraft`: a CLI built with Swift ArgumentParser.

## Features

- Swift Package Manager support
- macOS and iOS platform targets
- CLI entry point with ArgumentParser
- Clean separation between core logic and CLI
- Extensible structure for future commands and logic

## Installation

Clone and build locally:

```sh
git clone git@github.com:imnotnoahhh/daycraft-engine.git
cd daycraft-engine
swift build
```

Or add it to another Swift Package:

```swift
dependencies: [
    .package(url: "git@github.com:imnotnoahhh/daycraft-engine.git", from: "0.1.0")
]
```

## CLI Usage

Example 1: run the CLI from the package root.

```sh
swift run daycraft
```

Example 2: print the CLI version.

```sh
swift run daycraft --version
```

## API Usage

Example 1: basic usage from Swift.

```swift
import DaycraftLogic

let brain = DaycraftBrain()
print(brain.sayHello())
```

Example 2: wrap it in your own helper.

```swift
import DaycraftLogic

func makeGreeting() -> String {
    let brain = DaycraftBrain()
    return brain.sayHello()
}
```

## Contributing

Issues and pull requests are welcome. Please keep changes focused and add tests when you extend core behavior.

## Roadmap

- Extend core logic with additional, testable behaviors
- Add more CLI commands on top of the core library
- Keep the package structure clean as the project grows
