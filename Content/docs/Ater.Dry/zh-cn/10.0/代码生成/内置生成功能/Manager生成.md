# Manager生成

Manager是业务逻辑层的主要实现部分，内置工具可以在此生成常见的CURD代码。本文将说明Manager生成的细节。

**支持方式：`Studio`和`MCP`**

## 前提

- 根据特定实体进行生成

## 生成行为

生成时，会根据实体所有的目录结构，来识别所属模块。在生成前，最好先添加对应的模块。

Manager需要使用Dto，所以在生成Manager时，会先生成所需要的DTO。

### ManagerBase

内置生成的Manager类都会继承自`ManagerBase`类，以使用其中的方法来实现数据操作。

### 默认生成方法

内置工具会生成以下常见的CURD方法：

| 方法名             | 说明             |
| ------------------ | ---------------- |
| FilterAsync        | 带分页的筛选     |
| AddAsync           | 添加实体         |
| EditAsync          | 编辑实体         |
| GetAsync           | 获取实体详情     |
| DeleteAsync        | 删除实体(可批量) |
| HasPermissionAsync | 检查权限         |
| GetOwnedIdsAsync   | 获取拥有的ID列表 |
