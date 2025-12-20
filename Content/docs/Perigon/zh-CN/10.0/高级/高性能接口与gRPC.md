# GRPC

ASP.NET Core对gRPC服务有良好的支持，可以用来构建高性能的分布式系统和微服务架构。

## 性能说明

gPRC的高性能，主要是因为它使用了HTTP/2协议和Protocol Buffers序列化格式。HTTP/2支持多路复用、头部压缩和服务器推送等特性，减少了网络延迟和带宽消耗。Protocol Buffers是一种高效的二进制序列化格式，比JSON或XML更小更快。

这有两个核心点：

- HTTP/2
- Protocol Buffers

那么如果我们的接口使用了HTTP/2和Protocol Buffers，性能不也会得到提升吗？

## 自定义格式化程序

在ASP.NET Core中，我们可以同时支持Json和Protocol Buffers两种格式，来满足不同客户端的需求。

从[官方文档](https://learn.microsoft.com/zh-cn/aspnet/core/web-api/advanced/custom-formatters?view=aspnetcore-10.0)中，我们可以了解到如何自定义格式化程序。

这样我们可以同时处理`XML`、`Protocol Buffers`、`MessagePack`等多种序列化格式，而不需要对现有项目代码做出破坏性改动。

同样的，根据[官方文档](https://learn.microsoft.com/zh-cn/aspnet/core/fundamentals/servers/kestrel/endpoints?view=aspnetcore-10.0#configure-http-protocols)，我们可以配置Kestrel服务器来支持特定的HTTP协议版本。

## 总结

如果考虑性能原因，gRPC并不是唯一的选择，它只是使用了特定技术栈的一个实现，并且需要一定的学习成本和使用经验。

gRPC的便捷主要体现在，提供了不同语言的客户端支持，简化了跨语言调用的复杂性。