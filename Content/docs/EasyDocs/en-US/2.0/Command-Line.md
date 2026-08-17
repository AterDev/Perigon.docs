# Command Line

The installed executable is `ezdoc`. Run it without arguments or with `--help` to see the current command reference:

```powershell
ezdoc --help
```

## Commands

### `init [path]`

Initialize a site workspace at `path`. If `path` is omitted, the current directory is used.

```powershell
ezdoc init .
ezdoc init .\MyDocs
```

### `build [configPath]`

Build the static site described by `webinfo.json`.

```powershell
ezdoc build .\webinfo.json
```

## Global options

- `-h`, `--help`: print help for the application or the selected command;
- `-v`, `--version`: print the installed package version.

The command names remain `init` and `build` in every locale. The CLI loads one localized resource set from the current UI culture: Chinese systems show Chinese descriptions, while English systems show English descriptions. Set `DOTNET_CLI_UI_LANGUAGE` to `zh-CN` or `en-US` to override the detected culture. Build output uses styled success, information, warning, and error messages when the terminal supports ANSI colors.
