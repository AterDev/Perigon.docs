# EasyDocs 2.0

EasyDocs is a .NET command-line tool that turns Markdown content into a pure static website. The generated site contains HTML, CSS, JavaScript, JSON, and copied assets, so it can be deployed to GitHub Pages, a CDN, or any ordinary static-file server.

- Documentation site: [https://dusi.dev/docs/EasyDocs.html](https://dusi.dev/docs/EasyDocs.html)
- Source repository: [https://github.com/AterDev/EasyDocs](https://github.com/AterDev/EasyDocs)

## What it generates

An EasyDocs site can contain:

- a homepage and an about page;
- blog lists, blog catalogs, and Markdown blog pages;
- versioned and multilingual documentation;
- multilingual product landing pages and product documentation;
- search data, search pages, canonical links, and a sitemap;
- custom CSS, JavaScript, HTML, images, and other static files.

EasyDocs does not run a web server in the generated site. The output directory is the deployment artifact.

## Version model

The documentation version `2.0` is the version segment in the content tree and in `DocInfos[].Versions`. It is independent from the NuGet package version. A site can publish several documentation versions at the same time, while the CLI package can continue to receive patch releases.

## Reading order

Start with [Installation](Installation.md), then follow [Quick Start](Quick-Start.md). [Configuration](Configuration.md) and [Content Structure](Content-Structure.md) explain the files that EasyDocs reads. Use [Command Line](Command-Line.md) for the CLI reference and [Products](Products.md) for product content.
