# gRPC

ASP.NET Core offers first-class gRPC support, making it a strong option for high-performance distributed systems and microservices.

## Why gRPC Performs Well

gRPC’s throughput largely comes from HTTP/2 plus Protocol Buffers. HTTP/2 brings multiplexing, header compression, and server push, reducing latency and bandwidth. Protocol Buffers is a compact binary format that’s smaller and faster than JSON or XML.

The two key ingredients are:

- HTTP/2
- Protocol Buffers

This raises a practical question: if a REST API also uses HTTP/2 and a compact serializer, can it close the gap?

## Custom Formatters

In ASP.NET Core, you can support both JSON and Protocol Buffers (and others) simultaneously to suit different clients.

See the docs on [custom formatters](https://learn.microsoft.com/en-us/aspnet/core/web-api/advanced/custom-formatters?view=aspnetcore-10.0). This lets you add formats like XML, Protocol Buffers, and MessagePack without invasive changes.

You can also configure Kestrel to select specific HTTP protocol versions. See [Configure HTTP protocols](https://learn.microsoft.com/en-us/aspnet/core/fundamentals/servers/kestrel/endpoints?view=aspnetcore-10.0#configure-http-protocols).

## Summary

If performance is the only goal, gRPC isn’t the only answer—it’s one implementation choice with its own learning curve and trade-offs. A REST API using HTTP/2 and an efficient serializer can also perform very well.

gRPC’s biggest convenience is robust client support across languages, which simplifies cross-language calls.
