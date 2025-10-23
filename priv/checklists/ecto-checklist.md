# Ecto Best Practices Checklist

Use this checklist when working with Ecto schemas, migrations, and database operations.

## Schema Design

### Fields
- [ ] All fields have appropriate types (:string, :integer, :decimal, :utc_datetime, etc.)
- [ ] String length limits defined where appropriate
- [ ] Decimal precision defined for money/currency fields
- [ ] Enum fields use Ecto.Enum with values list
- [ ] Virtual fields marked with `virtual: true`
- [ ] Default values set in database, not schema (unless virtual)

### Associations
- [ ] belongs_to associations have corresponding foreign_key
- [ ] has_many associations defined in both directions if needed
- [ ] many_to_many uses join table or has_many :through
- [ ] Foreign keys have on_delete strategy (:delete_all, :nilify_all, :nothing)
- [ ] Circular associations avoided or carefully managed

### Timestamps
- [ ] `timestamps()` macro used
- [ ] Type specified if not default: `timestamps(type: :utc_datetime)`
- [ ] Manual timestamp fields use :utc_datetime, not :naive_datetime

## Changesets

### Validation
- [ ] `cast/3` includes only fillable fields
- [ ] `validate_required/2` on all mandatory fields
- [ ] String format validated (email, URL, etc.)
- [ ] Number ranges validated (min, max)
- [ ] String lengths validated
- [ ] Custom validations for complex rules
- [ ] Virtual fields validated if used

### Constraints
- [ ] `unique_constraint` for unique indices
- [ ] `foreign_key_constraint` for foreign keys
- [ ] `check_constraint` for database-level checks
- [ ] `no_assoc_constraint` to prevent deletion with associations
- [ ] Constraints run AFTER database operation

### Embedded Schemas
- [ ] Embedded schemas for JSON fields
- [ ] `embeds_one` or `embeds_many` as appropriate
- [ ] Validation on embedded changesets
- [ ] JSON encoding/decoding handled

## Migrations

### Structure
- [ ] Migration files have descriptive names
- [ ] One logical change per migration
- [ ] Migrations are reversible (`down` function or `change`)
- [ ] Up and down tested
- [ ] Idempotent where possible

### Tables
- [ ] Primary key defined (usually bigserial `id`)
- [ ] Timestamps added (`timestamps()`)
- [ ] Foreign keys reference correct table
- [ ] On delete/update actions specified
- [ ] Table names are plural

### Indices
- [ ] Unique indices for unique constraints
- [ ] Foreign keys have indices
- [ ] Commonly queried fields indexed
- [ ] Composite indices for multi-column queries
- [ ] Index names follow convention or explicitly set

### Data Types
- [ ] Appropriate type for each column
- [ ] :text for unlimited strings
- [ ] :string with limit for limited strings
- [ ] :decimal for money (not :float)
- [ ] :utc_datetime for timestamps
- [ ] :map or :jsonb for JSON data

### Constraints
- [ ] NOT NULL on required fields
- [ ] CHECK constraints for business rules
- [ ] UNIQUE constraints as needed
- [ ] Foreign key constraints
- [ ] Reasonable default values

## Queries

### Query Construction
- [ ] Use Ecto.Query DSL, not raw SQL
- [ ] Queries are composable (use from, where, select, etc.)
- [ ] Preload associations to avoid N+1
- [ ] Use join when filtering by association
- [ ] Use subquery when needed for complex queries

### Preloading
- [ ] `preload` for simple associations
- [ ] `preload: [assoc: query]` for filtered associations
- [ ] Preload in single query when possible
- [ ] Avoid preloading in loops

### Performance
- [ ] No N+1 queries (use preload or join)
- [ ] Select only needed fields in large queries
- [ ] Pagination for large result sets
- [ ] Limit used when only some records needed
- [ ] Indices support WHERE clauses

### Transactions
- [ ] Multi-step operations use Repo.transaction
- [ ] Ecto.Multi for complex transactions
- [ ] Rollback on error
- [ ] Keep transactions short

## Repository Operations

### Insert/Update/Delete
- [ ] Use context functions, not Repo calls directly
- [ ] Handle {:ok, result} and {:error, changeset} tuples
- [ ] Use bang variants (!) when failure should raise
- [ ] Use insert_all for bulk inserts
- [ ] Use update_all for bulk updates

### Error Handling
- [ ] Changeset errors are user-friendly
- [ ] Constraint violation errors handled
- [ ] Database connection errors handled
- [ ] Timeout errors handled appropriately

## Multi-Tenancy

If implementing multi-tenancy:

### Schema Level
- [ ] tenant_id on all relevant tables
- [ ] tenant_id in unique constraints
- [ ] Foreign keys scoped to tenant when appropriate
- [ ] Data isolation verified

### Query Level
- [ ] All queries filter by tenant_id
- [ ] No cross-tenant data leakage
- [ ] Authorization checks per tenant
- [ ] Tests verify tenant isolation

## Testing

### Schema Tests
- [ ] Changeset validations tested
- [ ] Required fields tested
- [ ] Format validations tested (email, etc.)
- [ ] Unique constraints tested
- [ ] Foreign key constraints tested
- [ ] Custom validations tested

### Query Tests
- [ ] Queries return expected results
- [ ] Filters work correctly
- [ ] Preloads work correctly
- [ ] Edge cases tested (empty results, etc.)

## Examples

### Good Schema Design
```elixir
schema "users" do
  field :email, :string
  field :name, :string
  field :role, Ecto.Enum, values: [:admin, :user, :guest]
  field :password, :string, virtual: true
  field :password_hash, :string

  belongs_to :organization, Organization
  has_many :posts, Post
  has_many :comments, Comment

  timestamps(type: :utc_datetime)
end

def changeset(user, attrs) do
  user
  |> cast(attrs, [:email, :name, :role, :password, :organization_id])
  |> validate_required([:email, :name, :organization_id])
  |> validate_format(:email, ~r/@/)
  |> validate_length(:name, min: 2, max: 100)
  |> validate_inclusion(:role, [:admin, :user, :guest])
  |> unique_constraint(:email)
  |> foreign_key_constraint(:organization_id)
  |> hash_password()
end
```

### Good Migration
```elixir
def change do
  create table(:users) do
    add :email, :string, null: false
    add :name, :string, null: false
    add :role, :string, null: false, default: "user"
    add :password_hash, :string, null: false
    add :organization_id, references(:organizations, on_delete: :delete_all), null: false

    timestamps(type: :utc_datetime)
  end

  create unique_index(:users, [:email])
  create index(:users, [:organization_id])
  create index(:users, [:email, :organization_id])
end
```

### Good Query
```elixir
def list_active_users_with_posts(organization_id) do
  from(u in User,
    where: u.organization_id == ^organization_id,
    where: u.active == true,
    preload: [:posts],
    order_by: [desc: u.inserted_at]
  )
  |> Repo.all()
end
```

## Common Pitfalls

❌ **Using floats for money**
```elixir
field :price, :float  # WRONG - precision issues
field :price, :decimal  # CORRECT
```

❌ **N+1 queries**
```elixir
# Bad - N+1 query
users = Repo.all(User)
Enum.map(users, fn user -> user.posts end)  # Queries for each user!

# Good - preload
users = Repo.all(User) |> Repo.preload(:posts)
Enum.map(users, fn user -> user.posts end)  # Already loaded
```

❌ **Not using constraints**
```elixir
# Bad - no constraint
def changeset(user, attrs) do
  user
  |> cast(attrs, [:email])
  |> validate_required([:email])
  # Email might still duplicate!
end

# Good - with constraint
def changeset(user, attrs) do
  user
  |> cast(attrs, [:email])
  |> validate_required([:email])
  |> unique_constraint(:email)  # Catches DB-level duplicates
end
```

❌ **Missing foreign key indices**
```elixir
# Bad - no index on foreign key
create table(:posts) do
  add :user_id, references(:users)
end

# Good - with index
create table(:posts) do
  add :user_id, references(:users)
end
create index(:posts, [:user_id])
```

❌ **Not handling errors**
```elixir
# Bad - unhandled error
def create_user(attrs) do
  %User{}
  |> User.changeset(attrs)
  |> Repo.insert!()  # Raises on error!
end

# Good - returns tuple
def create_user(attrs) do
  %User{}
  |> User.changeset(attrs)
  |> Repo.insert()  # Returns {:ok, user} or {:error, changeset}
end
```

## Performance Tips

- **Use select to load only needed fields** for large datasets
- **Use pagination** (limit + offset or cursor-based)
- **Add indices** for WHERE, ORDER BY, and JOIN columns
- **Use insert_all/update_all** for bulk operations
- **Profile queries** in development with `config :logger, :console, format: "[$level] $message\n"`
- **Monitor slow queries** in production

## Before Merging

- [ ] All migrations tested (up and down)
- [ ] All constraints have corresponding validations
- [ ] No N+1 queries introduced
- [ ] Indices added for foreign keys and common queries
- [ ] Changesets validate all business rules
- [ ] Tests cover happy path and error cases
- [ ] Schema documentation complete
