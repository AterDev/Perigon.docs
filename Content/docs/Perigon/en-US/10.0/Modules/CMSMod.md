# CMSMod

`Perigon.CMSMod` adds article-category and article management to `AdminService`. It suits projects that maintain announcements, news, or other structured content in an administration application.

## Capabilities

- Create, edit, list, and delete hierarchical article categories.
- Create, edit, filter, view, and delete articles.
- Articles support Chinese and English, plus content types such as news, viewpoint, knowledge, documentary, and private.
- Article bodies can use Markdown. The image-upload endpoint accepts PNG, JPEG, GIF, and WebP files up to 10 MB each.
- Articles record public visibility, originality, and audit state.

## Typical workflow

1. Create a category, then create an article under that category.
2. Edit the title, summary, body, language, content type, visibility, and originality. Upload images for Markdown content through the image endpoint.
3. Authors can view, edit, and delete their own articles. Administrators can manage articles in the current tenant.

Main endpoints:

- Articles: `GET /api/Article/list`, `POST /api/Article`, and `GET/PATCH/DELETE /api/Article/{id}`.
- Image upload: `POST /api/Article/images`.
- Categories: `GET /api/ArticleCategory/list`, `POST /api/ArticleCategory`, and `GET/PATCH/DELETE /api/ArticleCategory/{id}`.

The frontend includes article list, edit, and detail pages, plus category management at `/cms/article` and `/cms/article-category`. Article lists can be filtered by title, language, content type, audit/public/original state, author user, and category.

## Boundaries

- CMSMod currently provides administration APIs, not a separate public article-reading API.
- Articles record audit state, but there is no audit queue or approve/reject workflow; new articles start unaudited.
- Category APIs are scoped to the creating user. The current category update endpoint changes the name only; it does not expose parent-category changes.
- Uploaded images are returned as public relative paths. The module does not include file-cleanup jobs or its own access-control policy for uploaded files.

## Install and integrate

```pwsh
perigon module install Perigon.CMSMod AdminService
```

Register the module through the target service's `AddModules()` entry point and apply its database migrations. To use the administration pages, add the CMS frontend module and its menus to the Angular application. The Markdown editor also requires the module's editor dependencies. See the [module CLI guide](../Code-Generation/Command-Line.md) for frontend package options.
