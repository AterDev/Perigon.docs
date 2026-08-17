# Deployment and Customization

The directory in `OutputPath` is a complete static site. Deploy all of its files to the target host; no .NET runtime is required there.

## Deploying under a subpath

Set `BaseHref` to the deployment prefix, including the trailing slash:

```json
{
  "BaseHref": "/docs/"
}
```

Rebuild after changing it. Generated navigation links, scripts, stylesheets, canonical URLs, and sitemap entries use the configured base path.

## Custom assets

Place files under `Content/custom` to override packaged assets or add static files:

```text
Content/custom/
├── css/app.css
├── css/docs.css
├── js/site.js
└── images/banner.svg
```

Custom files are copied after built-in generation. A file at the same relative path replaces the generated file. New CSS or JavaScript is copied but is not automatically injected into every built-in page; override a template or an existing packaged asset when it must be loaded globally.

## CI builds

A simple CI step is:

```powershell
dotnet tool install -g Ater.EasyDocs
ezdoc build ./webinfo.json
```

Publish the resulting `OutputPath` directory with the hosting provider's static-site action.
