# Quick Start

Create or select a repository for the site content, then initialize it:

```powershell
mkdir MyDocs
cd MyDocs
ezdoc init .
```

`init` creates `webinfo.json`, a `Content` directory, example documentation directories, a blog directory, and `about.md`. The path is optional; without it, the current directory is used.

Add Markdown files under `Content`, then build the site:

```powershell
ezdoc build .\webinfo.json
```

The output directory is controlled by `OutputPath` and defaults to `./WebSite`. Preview it with any static-file server:

```powershell
npx http-server .\WebSite
```

## A minimal workflow

1. Keep `webinfo.json` at the repository root.
2. Put blogs, docs, products, and custom assets under `Content`.
3. Declare every documentation project, language, and version in `DocInfos`.
4. Run `ezdoc build .\webinfo.json` after content changes.
5. Deploy the complete output directory.

The generator can be run from any directory when the configuration path is supplied explicitly.
