# Cache Operations

In the template, we will use `HybridCache` as the caching solution. `HybridCache` is a hybrid caching system that combines local cache and distributed cache, which can improve performance while ensuring data consistency and reliability. It is officially maintained by Microsoft and released as the `Microsoft.Extensions.Caching.Hybrid` package.


## CacheService

The template framework uses `HybridCache` by default to implement cache operations and encapsulates it through `CacheService`. You can find its implementation in the `Share` project.


Its default configuration can be configured in `appsettings.json`:

```json
  // Cache configuration
  "Cache": {
    // Max payload bytes
    "MaxPayloadBytes": 1048576,
    // Key length
    "MaxKeyLength": 1024,
    // Expiration minutes
    "Expiration": 20,
    "LocalCacheExpiration": 10
  },
```

For more information, refer to the [official documentation](https://learn.microsoft.com/en-us/aspnet/core/performance/caching/hybrid?view=aspnetcore-10.0)
