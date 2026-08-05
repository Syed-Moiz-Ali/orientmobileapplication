# API Versioning

## Strategy: URL version (primary) + header negotiation (opt-in)

The API is versioned in layers so **v1 keeps working forever** and v2 can be
added without touching any existing code.

### 1. URL version (`/api/v1`)
The whole API lives under a configurable context path:

```properties
server.servlet.context-path=${API_CONTEXT_PATH:/api/v1}
```

- **v1 is the default** - every deployment today serves `/api/v1/*`.
- To roll the entire API to a new major version, deploy with
  `API_CONTEXT_PATH=/api/v2` (all endpoints move together). Existing v1
  deployments are never modified, so older clients keep working.
- For **partial** v2 additions (recommended), add *new* controllers under
  `/api/v2/...` in a shared deployment - they reuse the same services.
  Existing v1 controllers are untouched.

### 2. Header negotiation (fine-grained, per-request)
Clients may pin a version explicitly:

```
X-API-Version: 2
```

or via media range:

```
Accept: application/vnd.orient.v2+json
```

- Absent header -> current version (fully backward compatible).
- Unsupported version -> `406 Not Acceptable` with the supported list in the body.

### 3. Version metadata
```
GET /api/v1/version
```
returns `apiVersion`, `supportedVersions`, `urlPrefix`, the negotiation header
contract and the default version. Public (no auth).

## Rules for adding v2
1. Never edit an existing v1 controller/endpoint response shape.
2. New endpoints: new controller or new method, mapped under `/api/v2`.
3. Shared business logic stays in services (no duplication).
4. When a breaking change is unavoidable, ship the v2 endpoint *first*, then
   deprecate v1 (keep it running), then remove v1 in a later major release.

## Configuration
| Property | Default | Meaning |
|---|---|---|
| `API_CONTEXT_PATH` | `/api/v1` | URL prefix for the entire API |
| `app.api.version` | `1` | Version reported by `/version` |
| `app.api.supported-versions` | `1` | Comma-separated versions accepted by the interceptor |

Both current Flutter apps point at `/api/v1` and keep working unchanged.
