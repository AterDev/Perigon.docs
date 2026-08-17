# Content Structure

The default content tree looks like this:

```text
Content/
├── about.md
├── blogs/
├── custom/
├── docs/
│   └── EasyDocs/
│       ├── en-US/2.0/
│       └── zh-CN/2.0/
└── products/
    └── MyProduct/
        ├── logo.svg
        ├── en-US/
        └── zh-CN/
```

## Blogs

Every Markdown file under `Content/blogs` becomes a blog page. Subdirectories become blog catalogs. Images and other static files are copied to the corresponding output path.

## Documentation

Documentation follows `docs/<name>/<language>/<version>/...`. The name, language, and version must be present in `DocInfos`. For example:

```text
Content/docs/EasyDocs/en-US/2.0/Quick-Start.md
```

becomes:

```text
WebSite/docs/EasyDocs/en-US/2.0/Quick-Start.html
```

Use a `.order` file to mix Markdown files and directories in a predictable order. Entries do not include the `.md` suffix:

```text
Introduction
Quick-Start
Advanced
FAQ
```

Relative Markdown links are converted from `.md` to `.html`. Absolute HTTP(S) links are left unchanged. Files under `custom` are copied last and can override packaged CSS, JavaScript, templates, or generated pages.
