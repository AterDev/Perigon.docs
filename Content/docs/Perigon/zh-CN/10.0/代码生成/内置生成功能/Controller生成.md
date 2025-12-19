# Controller 生成

提供对符合框架设计的 API Controller 的生成支持。

**支持方式：`Studio`和`MCP`**

## 前提

- 根据特定实体进行生成
- 需要选择至少一个服务项目，以确定生成的位置

## 生成行为

- Controller 本身依赖于 Manager和DTO，所以在生成Controller时，会先生成所需要的DTO与Manager。
- 生成的控制器继承`RestControllerBase`.
- 会根据实体所属模块，添加控制器子目录.

### 默认生成方法

内置工具会生成以下常见的CURD方法：


| 方法名      | 说明         |
| ----------- | ------------ |
| ListAsync   | 带分页的筛选 |
| AddAsync    | 添加实体     |
| UpdateAsync | 编辑实体     |
| DetailAsync | 获取实体详情 |
| DeleteAsync | 删除实体     |
