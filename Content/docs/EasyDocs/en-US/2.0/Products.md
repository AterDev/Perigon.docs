# Product Content

Products are independent from versioned `DocInfos`. Configure them in `ProductInfos`:

```json
{
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

The matching content tree is:

```text
Content/products/MyProduct/
├── logo.svg
├── privacy-policy.html
├── en-US/
│   ├── .order
│   └── Getting-Started.md
└── zh-CN/
    ├── .order
    └── Getting-Started.md
```

The first Markdown document in `DefaultLanguage` is used for the product entry page:

```text
products/MyProduct.html
```

Language documentation is generated under `products/MyProduct/<language>/...`. Each language also receives a search page and JSON search data. The product navigation, language switcher, table of contents, canonical URLs, edit links, and sitemap entries are generated independently from the Docs pipeline.

Every non-Markdown file under the product root is copied unchanged. For example, `privacy-policy.html` remains available at `products/MyProduct/privacy-policy.html`; EasyDocs does not rewrite its HTML or internal links.
