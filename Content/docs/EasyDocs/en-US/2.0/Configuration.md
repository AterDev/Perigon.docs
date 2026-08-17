# Configuration

EasyDocs reads one JSON configuration file. The following example includes the site, documentation, and product settings used by the built-in builders:

```json
{
  "Name": "My Documentation",
  "Description": "A static documentation site",
  "AuthorName": "Ater",
  "ContetPath": "./Content",
  "OutputPath": "./WebSite",
  "BaseHref": "/",
  "Domain": "https://example.com",
  "RepositoryUrl": "https://github.com/example/docs",
  "Branch": "main",
  "Icon": "favicon.ico",
  "DocInfos": [
    {
      "Name": "EasyDocs",
      "Languages": ["en-US", "zh-CN"],
      "Versions": ["2.0"]
    }
  ],
  "ProductInfos": [
    {
      "Name": "MyProduct",
      "Description": "A multilingual product guide",
      "Logo": "logo.svg",
      "Languages": ["en-US", "zh-CN"],
      "DefaultLanguage": "en-US"
    }
  ]
}
```

## Important properties

- `ContetPath` is intentionally spelled with the existing compatibility typo. Do not rename it to `ContentPath` in existing configuration files.
- `OutputPath` is the generated static-site directory.
- `BaseHref` must end with `/`. Use `/` for a site deployed at the domain root.
- `Domain` is optional. When present, it is used to build canonical URLs and `sitemap.xml`.
- `RepositoryUrl` and `Branch` enable documentation edit links.
- `DocInfos` declares documentation names, languages, and versions. Every declaration must have a matching directory.
- `ProductInfos` declares products and their supported languages. `DefaultLanguage` must be listed in `Languages` and its directory must exist.

Property names are case-sensitive in the JSON contract. Language and version directory names should match the configured values exactly.
