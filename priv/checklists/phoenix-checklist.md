# Phoenix Best Practices Checklist

Use this checklist when implementing Phoenix features to ensure you're following established patterns and best practices.

## Context Design

### Bounded Context
- [ ] Context has a clear, single responsibility
- [ ] Context name represents a domain concept (Accounts, Billing, Content, not "Helpers")
- [ ] Public API is minimal and well-defined
- [ ] Internal/private functions are clearly marked
- [ ] No circular dependencies between contexts

### Functions
- [ ] Public functions document their return types
- [ ] Functions return `{:ok, result}` or `{:error, reason}` tuples
- [ ] Bang functions (!) raise exceptions for expected errors
- [ ] Query functions don't have side effects
- [ ] Mutations clearly indicate they modify data

## Controllers

### Structure
- [ ] Controllers are thin - business logic in contexts
- [ ] One action per HTTP verb per resource
- [ ] Error handling via action fallback controller
- [ ] Proper status codes returned (200, 201, 204, 400, 404, etc.)

### JSON APIs
- [ ] Request validation in changeset, not controller
- [ ] Consistent JSON response format
- [ ] Proper error messages in responses
- [ ] API versioning if public API

### Web Controllers
- [ ] Flash messages for user feedback
- [ ] Redirects after POST/PUT/DELETE
- [ ] Form errors displayed clearly
- [ ] CSRF protection enabled

## Router

### Routes
- [ ] RESTful routes follow conventions
- [ ] Nested routes limited to 1-2 levels
- [ ] Named routes used in templates (`~p"/users/#{user}"`)
- [ ] Routes organized by concern/context
- [ ] API routes use `/api` prefix

### Pipelines
- [ ] Auth requirements in router, not individual actions
- [ ] Pipelines composed of small, focused plugs
- [ ] Browser pipeline includes CSRF, fetch session/flash
- [ ] API pipeline minimal (no CSRF, session)

## Templates & Components

### HEEx Templates
- [ ] Use function components (`<.component>`) from core_components
- [ ] Minimize logic in templates
- [ ] Extract reusable markup to components
- [ ] No inline styles (use Tailwind classes)
- [ ] Accessibility attributes (aria-*, alt, label)

### Components
- [ ] Components are pure functions
- [ ] Slots used for flexible layouts
- [ ] Props validated with attr/3
- [ ] Reusable across contexts
- [ ] Well-documented with examples

## Security

### Authentication & Authorization
- [ ] Authentication in plug pipeline
- [ ] Authorization checks in every action
- [ ] Can't access other users' data
- [ ] Proper session management
- [ ] Secure password hashing (bcrypt)

### Input Validation
- [ ] All user input validated
- [ ] Changeset validations comprehensive
- [ ] SQL injection prevented (use Ecto queries)
- [ ] XSS prevented (HEEx auto-escapes)
- [ ] CSRF protection enabled

### Secrets
- [ ] No secrets in source code
- [ ] Environment variables for config
- [ ] Secret key base properly set
- [ ] API keys not committed

## Performance

### Database Queries
- [ ] No N+1 queries (use preload or join)
- [ ] Indices on foreign keys
- [ ] Indices on frequently queried fields
- [ ] Pagination for large result sets
- [ ] Use `select` to limit fields loaded

### Caching
- [ ] Expensive computations cached
- [ ] Cache invalidation strategy clear
- [ ] ETag/conditional requests for APIs
- [ ] Static assets fingerprinted

## Error Handling

### User-Facing Errors
- [ ] Friendly error messages
- [ ] 404 page customized
- [ ] 500 page customized
- [ ] Error tracking configured (Sentry, AppSignal, etc.)

### Developer Errors
- [ ] Useful error messages in logs
- [ ] Stack traces in development
- [ ] No sensitive data in error messages
- [ ] Error rates monitored

## Testing

### Coverage
- [ ] All public context functions tested
- [ ] All controller actions tested
- [ ] Happy path covered
- [ ] Error cases covered
- [ ] Edge cases identified and tested

### Test Quality
- [ ] Tests are readable and maintainable
- [ ] Factory/fixture functions for test data
- [ ] Tests isolated (no shared state)
- [ ] Fast test suite (< 30s for full run)
- [ ] Async tests where possible

## Documentation

### Code Documentation
- [ ] @moduledoc on all public modules
- [ ] @doc on all public functions
- [ ] Examples in @doc blocks
- [ ] Complex logic explained with comments
- [ ] README up to date

### API Documentation
- [ ] API endpoints documented (Swagger/OpenAPI)
- [ ] Request/response examples provided
- [ ] Error responses documented
- [ ] Rate limiting documented

## Configuration

### Environments
- [ ] Development config for local work
- [ ] Test config isolated
- [ ] Production config secure
- [ ] Runtime config in releases

### Dependencies
- [ ] Minimal dependencies
- [ ] Dependencies up to date
- [ ] Security vulnerabilities checked (`mix deps.audit`)
- [ ] Unused deps removed

## Deployment

### Release
- [ ] Mix release configured
- [ ] Migrations run automatically or documented
- [ ] Health check endpoint (`/health`)
- [ ] Graceful shutdown handling

### Monitoring
- [ ] Application metrics collected
- [ ] Error rates monitored
- [ ] Performance metrics tracked
- [ ] Logs aggregated and searchable

## Phoenix-Specific Patterns

### Contexts
✅ **Good:**
```elixir
# Public API
def get_user!(id), do: Repo.get!(User, id)
def list_users, do: Repo.all(User)
def create_user(attrs), do: %User{} |> User.changeset(attrs) |> Repo.insert()

# All Repo calls internal to context
```

❌ **Bad:**
```elixir
# Controller calling Repo directly
def index(conn, _params) do
  users = Repo.all(User)  # Should be in context!
  render(conn, "index.html", users: users)
end
```

### Controllers
✅ **Good:**
```elixir
def create(conn, %{"user" => user_params}) do
  case Accounts.create_user(user_params) do
    {:ok, user} ->
      conn
      |> put_flash(:info, "User created successfully")
      |> redirect(to: ~p"/users/#{user}")

    {:error, %Ecto.Changeset{} = changeset} ->
      render(conn, "new.html", changeset: changeset)
  end
end
```

❌ **Bad:**
```elixir
def create(conn, %{"user" => user_params}) do
  user = Accounts.create_user!(user_params)  # Unhandled exception!
  redirect(conn, to: ~p"/users/#{user}")
end
```

## Common Pitfalls to Avoid

- ❌ Putting business logic in controllers
- ❌ Accessing Repo directly from controllers
- ❌ Creating God contexts (split into smaller contexts)
- ❌ Not testing edge cases
- ❌ Ignoring N+1 query warnings
- ❌ Not using database constraints
- ❌ Storing sensitive data in plain text
- ❌ Not implementing authorization checks
- ❌ Using `belongs_to` without `foreign_key_constraint`
- ❌ Not paginating large result sets

## Before Marking Story Complete

- [ ] All checklist items above reviewed
- [ ] `mix test` - All tests passing
- [ ] `mix credo --strict` - No issues
- [ ] `mix dialyzer` - No warnings
- [ ] `mix format` - Code formatted
- [ ] No compiler warnings
- [ ] Documentation complete
- [ ] Security review done
- [ ] Performance acceptable
