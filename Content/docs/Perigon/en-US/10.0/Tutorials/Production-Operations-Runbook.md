# Production Operations Runbook

Use this runbook for release checks, incident diagnosis, and rollback for ApiStandard and MiniApi. Confirm the template boundary before applying a procedure.

## Pre-release checklist

- [ ] The template package, Aspire SDK, and runtime image versions match the [version compatibility matrix](../Project-Templates/Version-Features.md).
- [ ] `Authentication__Jwt__Sign` is injected through environment variables, a secret store, or a key service; no sample value is used.
- [ ] `Authentication__Jwt__ValidIssuer`, `Authentication__Jwt__ValidAudiences`, and the production HTTPS address are configured.
- [ ] OAuth metadata HTTPS validation is enabled; `RequireHttpsMetadata=false` is allowed only in Development.
- [ ] Production CORS allow-list is configured; `AllowAnyOrigin` is not used.
- [ ] Database connection, migration policy, backups, and restore points are documented.
- [ ] `OTEL_EXPORTER_OTLP_ENDPOINT` is configured when telemetry export is required; do not rely on the removed `Otel` or `OpenTelemetry` nodes.
- [ ] Load balancers have liveness/readiness checks for `/health` and `/alive`, with an explicit dependency-check policy.
- [ ] Container architecture, ports, certificates, image tags, and rollback images are verified.

## Migration failures

### ApiStandard

`ApiService-Migrations` is a one-shot migration resource. Inspect its logs and state first:

```powershell
aspire otel logs ApiService-Migrations
aspire describe ApiService-Migrations
```

1. Stop the release flow and do not send traffic to a partially migrated application.
2. Verify database connectivity, permissions, and the migration history table.
3. Fix the migration or seed data and rerun it against a test database.
4. In production, restore a verified backup before retrying a migration; do not delete the migration history table as a first response.
5. Start API and background services only after `ApiService-Migrations` completes successfully.

For a Kubernetes release, verify the Job:

```powershell
kubectl get jobs -n perigon -l app.kubernetes.io/component=ApiService-Migrations
kubectl describe job <migration-job-name> -n perigon
kubectl logs job/<migration-job-name> -n perigon
```

After success, the Job must not be treated as a long-running service. If it fails, stop traffic, fix the migration or seed data, and rerun the release flow. Do not delete the production EF history table as a first response.

### MiniApi

MiniApi has no `ApiService-Migrations` and no built-in EF migration script. A deployment pipeline or a dedicated database-change tool owns schema changes; the pipeline must validate the schema before starting the API.

## Container health

Inspect Aspire resources with:

```powershell
aspire ps
aspire describe
```

Use `/health` for readiness and `/alive` for liveness. If a resource remains `Unhealthy`:

1. Inspect application and infrastructure logs.
2. Verify that AppHost injected the expected `Default` and `Cache` connection strings.
3. Check `Components__Cache` (`Memory`, `Redis`, or `Hybrid`) and remember that Redis is required only for `Redis` or `Hybrid`.
4. Check container ports, volume permissions, image architecture, and resource limits.

## Aspire logs and traces

```powershell
aspire otel logs ApiService
aspire otel traces ApiService
aspire otel spans ApiService
```

The code discovers an OTLP exporter through the standard `OTEL_EXPORTER_OTLP_ENDPOINT` environment variable. The old `Otel`/`OpenTelemetry` configuration nodes were removed because they were not read by the service defaults.

## Rollback

- Application rollback: switch to the last verified image tag and retain current logs and deployment descriptions.
- Database rollback: restore a verified backup first; run a reverse migration only when it is explicitly tested and reversible.
- Configuration rollback: restore JWT issuer/audience, CORS, connection strings, and OTLP endpoint together to avoid version/configuration mismatch.
