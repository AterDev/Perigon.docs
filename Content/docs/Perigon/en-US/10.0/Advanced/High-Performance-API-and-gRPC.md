# gRPC

ASP.NET Core has good support for gRPC services and can be used to build high-performance distributed systems and microservice architectures.

## Performance Description

The high performance of gRPC is mainly because it uses HTTP/2 protocol and Protocol Buffers serialization format. HTTP/2 supports features such as multiplexing, header compression, and server push, reducing network latency and bandwidth consumption. Protocol Buffers is an efficient binary serialization format that is smaller and faster than JSON or XML.

There are two core points:

- HTTP/2
- Protocol Buffers

So if our APIs use HTTP/2 and Protocol Buffers, will the performance also be improved?

## Custom Formatters

In ASP.NET Core, we can support both Json and Protocol Buffers formats at the same time to meet the needs of different clients.

From the [official documentation](https://learn.microsoft.com/en-us/aspnet/core/web-api/advanced/custom-formatters?view=aspnetcore-10.0), we can learn how to customize formatters.

This way we can handle multiple serialization formats such as `XML`, `Protocol Buffers`, `MessagePack`, etc. at the same time without making destructive changes to existing project code.

Similarly, according to the [official documentation](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel/endpoints?view=aspnetcore-10.0#configure-http-protocols), we can configure the Kestrel server to support specific HTTP protocol versions.

## Summary

If considering performance reasons, gRPC is not the only choice. It is just an implementation using a specific technology stack and requires a certain learning cost and usage experience.

The convenience of gRPC is mainly reflected in the fact that it provides client support in different languages, simplifying the complexity of cross-language calls.
