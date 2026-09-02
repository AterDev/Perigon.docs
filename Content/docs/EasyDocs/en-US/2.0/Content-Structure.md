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

## Images in Markdown

Images do not have to be placed in a directory named `images`. EasyDocs resolves a local image path relative to the Markdown file, so the image can be beside the document or in any subdirectory:

```text
Content/docs/EasyDocs/en-US/2.0/
├── Quick-Start.md
├── logo.svg
└── assets/
    └── architecture.png
```

```markdown
![Logo](logo.svg)
![Architecture](assets/architecture.png)
```

For blogs and documentation, the builder currently copies local `.jpg`, `.jpeg`, `.png`, `.gif`, and `.svg` files under the corresponding content tree. Use a path relative to the Markdown file and keep the extension in lower case. Remote `http://` and `https://` image URLs are preserved and are not copied.

Versioned documentation pages support any matching relative image path. The generated documentation homepage at `docs/<name>.html` is based on the first document, and the current builder rewrites homepage image references only when they start with `./_images`. If the image must also appear on the documentation homepage, use this convention:

```text
Content/docs/EasyDocs/en-US/2.0/
├── Quick-Start.md
└── _images/
    └── architecture.png
```

```markdown
![Architecture](./_images/architecture.png)
```
