# Project Versioning


## Project Version Support

The project version is generally consistent with the version of .NET Core.

Perigon.CLI 10 is based on .NET 10 and is no longer compatible with previous versions.

Subsequent version plans will follow the following support rules:

- When the .NET version is an even version (starting from .NET 12), it will support the previous even version, the previous odd version, and the current version at the same time, for a total of three versions.
- When the .NET version is an odd version, it will only support the current version and the previous even version, for a total of two versions.

> [!NOTE]
> In reality, the above rules may not be followed exactly. The README document of the current version shall prevail.


## Project Version Number

The project version number follows the Semantic Versioning specification (SemVer), with the format `major.minor.patch`. The major version is consistent with the latest version of the current .NET.

Please use the `setVersion.ps1` script to set the version number, which will synchronize the version numbers of **command line/Studio/template** to maintain consistency.
