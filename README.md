# Koshchei
A small game written with the `Jai` programming language.

## Language notice
Since `Jai` is not available to the general public GitHub does not recognize it. For that reason 
I've manually set the highlighting to `C`, which will make GitHub do some highlighting but it 
will likely be broken in many cases since `Jai` is a completely different language.

## Structure
- See: [docs/Time.md](./docs/Time.md) for estimated time spent working on this project.
- See: [docs/Idea.md](./docs/Idea.md) for a rough idea of what this game is supposed to be.
- Configure the build metaprogram directly in: [build_config.jai](./build_config.jai).
- Simple scripts for running/building the project: [scripts](./scripts).

## Build
To build simply run:
```cmd
jai build.jai
```
or use the provided script: [scripts/build.bat](./scripts/build.bat) which does the same.

To change build parameters such as verbosity or level of optimization edit `build_config.jai`
directly.

## LICENSE
```txt
Copyright 2024, Filip Gacina

All rights reserved.
No part of this project, including code, assets, and documentation, may be used, copied,
modified, or distributed without explicit written permission from the author.
```
