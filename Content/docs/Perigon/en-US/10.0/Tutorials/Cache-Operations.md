# Cache Operations

The template uses `HybridCache`, a hybrid solution combining local and distributed caching for performance and consistency. Microsoft maintains it as `Microsoft.Extensions.Caching.Hybrid`.

## CacheService

The framework uses `HybridCache` and wraps it via `CacheService` in the `Share` project.

Configure in `appsettings.json`:

```json
  "Cache": {
    "MaxPayloadBytes": 1048576,
    "MaxKeyLength": 1024,
    "Expiration": 20,
    "LocalCacheExpiration": 10
  },
```

For more, see the [official docs](https://learn.microsoft.com/en-us/aspnet/core/performance/caching/hybrid?view=aspnetcore-10.0).
