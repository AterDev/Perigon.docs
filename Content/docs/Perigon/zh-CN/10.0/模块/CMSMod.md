# CMSMod

`Perigon.CMSMod` 为 `AdminService` 提供文章分类与文章管理能力，适用于在管理端维护公告、资讯和其他结构化内容的项目。

## 功能

- 创建、编辑、查询和删除文章分类；分类支持父子层级。
- 创建、编辑、分页筛选、查看和删除文章。
- 文章支持中文和英文语言，以及新闻、观点、知识、纪实和私密等内容类型。
- 文章正文可使用 Markdown；提供图片上传接口，允许 PNG、JPEG、GIF 和 WebP，单个文件最大 10 MB。
- 文章记录公开状态、原创标记和审核状态。

## 典型流程

1. 用户先创建文章分类，再在该分类下新建文章。
2. 编辑文章标题、摘要、正文、语言、内容类型、公开状态和原创标记；Markdown 正文中的图片可通过上传接口保存。
3. 文章作者可查看、修改和删除自己的文章；管理员可管理当前租户内的文章。

主要接口：

- 文章：`GET /api/Article/list`、`POST /api/Article`、`GET/PATCH/DELETE /api/Article/{id}`。
- 图片上传：`POST /api/Article/images`。
- 分类：`GET /api/ArticleCategory/list`、`POST /api/ArticleCategory`、`GET/PATCH/DELETE /api/ArticleCategory/{id}`。

模块前端提供文章列表、编辑、详情以及分类管理页面，菜单路径为 `/cms/article` 和 `/cms/article-category`。文章列表可按标题、语言、内容类型、审核/公开/原创状态、作者用户和分类筛选。

## 使用边界

- CMSMod 当前提供管理端接口，没有独立的公开文章查询 API。
- 文章保存审核状态，但当前没有审核队列、审核通过或驳回接口；新建文章初始为未审核。
- 分类接口按创建用户隔离。当前分类编辑接口只更新名称，父级调整没有通过接口开放。
- 图片以公开相对路径返回；模块不包含上传文件的清理任务或访问控制策略。

## 安装与接入

```pwsh
perigon module install Perigon.CMSMod AdminService
```

在目标服务中通过 `AddModules()` 注册模块并执行数据库迁移。使用管理页面时，还需将 CMS 前端模块和对应菜单纳入 Angular 应用；使用 Markdown 编辑器还需保留模块要求的编辑器依赖。具体模块包前端选项见[模块命令行文档](../代码生成/命令行.md)。
