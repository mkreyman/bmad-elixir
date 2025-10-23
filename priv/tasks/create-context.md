# Task: Create Phoenix Context

**Purpose**: Add a new bounded context to organize domain logic

**Agent**: elixir-dev

**Duration**: 2-4 hours

## Overview

Phoenix contexts are dedicated modules that expose and group related functionality. They provide a clean API boundary and encapsulate business logic.

## When to Create a Context

Create a new context when:
- Adding a new domain concept (Accounts, Catalog, Billing, etc.)
- Grouping related functionality that doesn't fit existing contexts
- Enforcing boundaries between different parts of the system

## Step 1: Define Context Boundary

**Duration**: 15-30 minutes

Answer these questions:
- What is the domain concept? (e.g., "Accounts" for user management)
- What operations will this context provide?
- What data does this context own?
- How does it relate to other contexts?

**Example:**
```
Domain: Catalog
Purpose: Manage products, categories, and inventory
Operations: CRUD for products, search, filtering, stock management
Owns: products, categories, product_categories tables
Relations:
  - Accounts context (products belong to sellers)
  - Orders context (order items reference products)
```

## Step 2: Generate Context with Schema

**Duration**: 5-10 minutes

Use Phoenix generator:

```bash
mix phx.gen.context ContextName SchemaName table_name field:type field:type ...
```

**Example:**
```bash
mix phx.gen.context Catalog Product products \
  name:string \
  description:text \
  price:decimal \
  sku:string:unique \
  quantity:integer \
  active:boolean
```

This generates:
- `lib/my_app/catalog.ex` - Context module with CRUD functions
- `lib/my_app/catalog/product.ex` - Schema module
- `priv/repo/migrations/20240115120000_create_products.exs` - Migration
- `test/my_app/catalog_test.exs` - Context tests
- `test/support/fixtures/catalog_fixtures.ex` - Test fixtures

## Step 3: Customize Schema

**Duration**: 30 minutes - 1 hour

### Add Associations

```elixir
# lib/my_app/catalog/product.ex
defmodule MyApp.Catalog.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :name, :string
    field :description, :string  # Note: Even :text columns use :string type
    field :price, :decimal
    field :sku, :string
    field :quantity, :integer
    field :active, :boolean, default: true

    # Add associations
    belongs_to :category, MyApp.Catalog.Category
    belongs_to :seller, MyApp.Accounts.User
    has_many :order_items, MyApp.Orders.OrderItem
    has_many :reviews, MyApp.Catalog.Review

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, [:name, :description, :price, :sku, :quantity, :active, :category_id])
    |> validate_required([:name, :price, :sku])
    |> validate_length(:name, min: 2, max: 100)
    |> validate_length(:description, max: 5000)
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:quantity, greater_than_or_equal_to: 0)
    |> validate_format(:sku, ~r/^[A-Z0-9-]+$/, message: "must be uppercase alphanumeric with hyphens")
    |> unique_constraint(:sku)
    |> foreign_key_constraint(:category_id)
    |> foreign_key_constraint(:seller_id)
  end
end
```

### Add Virtual Fields (if needed)

```elixir
schema "products" do
  # ... regular fields

  # Virtual field for search highlighting
  field :search_rank, :float, virtual: true

  # Virtual field for API responses
  field :display_price, :string, virtual: true
end
```

### Add Custom Validations

```elixir
def changeset(product, attrs) do
  product
  |> cast(attrs, [:name, :price, :quantity, :active])
  |> validate_required([:name, :price])
  |> validate_price_for_active_products()
  |> validate_stock_levels()
end

defp validate_price_for_active_products(changeset) do
  active = get_field(changeset, :active)
  price = get_field(changeset, :price)

  if active && Decimal.compare(price, 0) != :gt do
    add_error(changeset, :price, "must be greater than 0 for active products")
  else
    changeset
  end
end

defp validate_stock_levels(changeset) do
  quantity = get_field(changeset, :quantity)
  active = get_field(changeset, :active)

  if active && quantity == 0 do
    add_error(changeset, :quantity, "active products must have stock")
  else
    changeset
  end
end
```

## Step 4: Enhance Migration

**Duration**: 15-30 minutes

Add indices, constraints, and proper defaults:

```elixir
# priv/repo/migrations/20240115120000_create_products.exs
defmodule MyApp.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string, null: false
      add :description, :text
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :sku, :string, null: false
      add :quantity, :integer, default: 0, null: false
      add :active, :boolean, default: true, null: false

      # Foreign keys with on_delete actions
      add :category_id, references(:categories, on_delete: :nilify_all)
      add :seller_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    # Unique constraint
    create unique_index(:products, [:sku])

    # Foreign key indices
    create index(:products, [:category_id])
    create index(:products, [:seller_id])

    # Query optimization indices
    create index(:products, [:active])
    create index(:products, [:active, :category_id])

    # Full-text search index (PostgreSQL specific)
    execute(
      "CREATE INDEX products_name_trgm_idx ON products USING gin (name gin_trgm_ops)",
      "DROP INDEX products_name_trgm_idx"
    )

    # Check constraints
    create constraint(:products, :price_must_be_positive, check: "price > 0")
    create constraint(:products, :quantity_must_be_non_negative, check: "quantity >= 0")
  end
end
```

## Step 5: Implement Context API

**Duration**: 1-2 hours

### Basic CRUD Operations

The generator creates these, but customize as needed:

```elixir
# lib/my_app/catalog.ex
defmodule MyApp.Catalog do
  @moduledoc """
  The Catalog context.

  Manages products, categories, and inventory operations.
  """

  import Ecto.Query, warn: false
  alias MyApp.Repo
  alias MyApp.Catalog.Product

  @doc """
  Returns the list of products.

  ## Examples

      iex> list_products()
      [%Product{}, ...]

  """
  def list_products do
    Repo.all(Product)
  end

  @doc """
  Returns the list of products with filters and sorting.

  ## Options

    * `:preload` - List of associations to preload
    * `:filters` - Map of filters (active, category_id, search)
    * `:sort_by` - Field to sort by (default: :inserted_at)
    * `:sort_order` - :asc or :desc (default: :desc)

  ## Examples

      iex> list_products(preload: [:category], filters: %{active: true})
      [%Product{category: %Category{}}, ...]

  """
  def list_products(opts \\ []) do
    Product
    |> apply_filters(opts[:filters] || %{})
    |> apply_sorting(opts[:sort_by], opts[:sort_order])
    |> maybe_preload(opts[:preload])
    |> Repo.all()
  end

  defp apply_filters(query, filters) do
    Enum.reduce(filters, query, fn {key, value}, query ->
      apply_filter(query, key, value)
    end)
  end

  defp apply_filter(query, :active, value) do
    where(query, [p], p.active == ^value)
  end

  defp apply_filter(query, :category_id, value) do
    where(query, [p], p.category_id == ^value)
  end

  defp apply_filter(query, :search, value) when is_binary(value) do
    search_term = "%#{value}%"
    where(query, [p], ilike(p.name, ^search_term) or ilike(p.description, ^search_term))
  end

  defp apply_filter(query, :min_price, value) do
    where(query, [p], p.price >= ^value)
  end

  defp apply_filter(query, :max_price, value) do
    where(query, [p], p.price <= ^value)
  end

  defp apply_filter(query, _key, _value), do: query

  defp apply_sorting(query, nil, _order), do: order_by(query, [desc: :inserted_at])
  defp apply_sorting(query, field, :asc), do: order_by(query, [asc: ^field])
  defp apply_sorting(query, field, _order), do: order_by(query, [desc: ^field])

  defp maybe_preload(query, nil), do: query
  defp maybe_preload(query, preloads), do: preload(query, ^preloads)

  @doc """
  Gets a single product.

  Returns `{:ok, product}` if found, `{:error, :not_found}` otherwise.

  ## Examples

      iex> get_product(123)
      {:ok, %Product{}}

      iex> get_product(456)
      {:error, :not_found}

  """
  def get_product(id) do
    case Repo.get(Product, id) do
      nil -> {:error, :not_found}
      product -> {:ok, product}
    end
  end

  @doc """
  Gets a single product.

  Raises `Ecto.NoResultsError` if the Product does not exist.

  ## Examples

      iex> get_product!(123)
      %Product{}

      iex> get_product!(456)
      ** (Ecto.NoResultsError)

  """
  def get_product!(id), do: Repo.get!(Product, id)

  @doc """
  Creates a product.

  ## Examples

      iex> create_product(%{field: value})
      {:ok, %Product{}}

      iex> create_product(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_product(attrs \\ %{}) do
    %Product{}
    |> Product.changeset(attrs)
    |> Repo.insert()
    |> maybe_broadcast_change(:product_created)
  end

  @doc """
  Updates a product.

  ## Examples

      iex> update_product(product, %{field: new_value})
      {:ok, %Product{}}

      iex> update_product(product, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_product(%Product{} = product, attrs) do
    product
    |> Product.changeset(attrs)
    |> Repo.update()
    |> maybe_broadcast_change(:product_updated)
  end

  @doc """
  Deletes a product.

  ## Examples

      iex> delete_product(product)
      {:ok, %Product{}}

      iex> delete_product(product)
      {:error, %Ecto.Changeset{}}

  """
  def delete_product(%Product{} = product) do
    Repo.delete(product)
    |> maybe_broadcast_change(:product_deleted)
  end

  # PubSub broadcast for real-time updates
  defp maybe_broadcast_change({:ok, product}, event) do
    Phoenix.PubSub.broadcast(
      MyApp.PubSub,
      "products",
      {event, product}
    )

    {:ok, product}
  end

  defp maybe_broadcast_change(error, _event), do: error
end
```

### Advanced Query Functions

```elixir
@doc """
Returns products with low stock levels.
"""
def list_low_stock_products(threshold \\ 10) do
  Product
  |> where([p], p.quantity <= ^threshold)
  |> where([p], p.active == true)
  |> order_by([p], asc: p.quantity)
  |> Repo.all()
end

@doc """
Searches products using full-text search (PostgreSQL).
"""
def search_products(search_term) when is_binary(search_term) do
  from(p in Product,
    where: fragment("? % ?", p.name, ^search_term),
    order_by: fragment("similarity(?, ?) DESC", p.name, ^search_term),
    limit: 20
  )
  |> Repo.all()
end

@doc """
Returns paginated products.
"""
def paginate_products(page \\ 1, per_page \\ 20) do
  offset = (page - 1) * per_page

  products =
    Product
    |> limit(^per_page)
    |> offset(^offset)
    |> Repo.all()

  total_count = Repo.aggregate(Product, :count)

  %{
    entries: products,
    page_number: page,
    page_size: per_page,
    total_entries: total_count,
    total_pages: ceil(total_count / per_page)
  }
end
```

## Step 6: Write Tests

**Duration**: 1-2 hours

See `write-tests.md` for comprehensive testing guide.

```elixir
# test/my_app/catalog_test.exs
defmodule MyApp.CatalogTest do
  use MyApp.DataCase

  alias MyApp.Catalog

  describe "list_products/1" do
    test "returns all products" do
      product = product_fixture()
      assert Catalog.list_products() == [product]
    end

    test "filters by active status" do
      active = product_fixture(active: true)
      _inactive = product_fixture(active: false)

      assert Catalog.list_products(filters: %{active: true}) == [active]
    end

    test "preloads associations" do
      product = product_fixture()
      [loaded] = Catalog.list_products(preload: [:category])

      assert Ecto.assoc_loaded?(loaded.category)
    end
  end

  # ... more tests
end
```

## Step 7: Run Migration

```bash
# Development
mix ecto.migrate

# Test
MIX_ENV=test mix ecto.migrate
```

## Context Best Practices

### Keep Contexts Focused

✅ **Good:** Small, focused contexts
```
Accounts (users, authentication)
Catalog (products, categories)
Orders (orders, order_items, payments)
```

❌ **Bad:** God context
```
Store (users, products, orders, payments, shipping, reviews, etc.)
```

### Public vs Private Functions

```elixir
# Public API - documented and stable
def list_products(opts \\ [])
def get_product(id)
def create_product(attrs)

# Private helpers - can change freely
defp apply_filters(query, filters)
defp maybe_broadcast_change(result, event)
```

### Never Expose Ecto.Changeset in Public API

✅ **Good:**
```elixir
@spec create_product(map()) :: {:ok, Product.t()} | {:error, Ecto.Changeset.t()}
def create_product(attrs)
```

❌ **Bad:**
```elixir
# Don't expose changeset creation
def product_changeset(attrs)
```

### Avoid Cross-Context Database Queries

✅ **Good:** Call other context's public API
```elixir
def list_user_products(user_id) do
  # Don't query Accounts.User directly
  {:ok, user} = Accounts.get_user(user_id)

  Product
  |> where(seller_id: ^user.id)
  |> Repo.all()
end
```

❌ **Bad:** Reach into other context's tables
```elixir
def list_user_products(user_id) do
  # Don't do this - violates context boundary!
  from(p in Product,
    join: u in Accounts.User,
    where: u.id == ^user_id and p.seller_id == u.id
  )
  |> Repo.all()
end
```

## Common Pitfalls

### Missing Preloads (N+1 Queries)

```elixir
# Bad: N+1 query
products = Catalog.list_products()
Enum.each(products, fn product ->
  IO.puts product.category.name  # Queries for each product!
end)

# Good: Preload associations
products = Catalog.list_products(preload: [:category])
Enum.each(products, fn product ->
  IO.puts product.category.name  # Already loaded
end)
```

### Not Using Database Constraints

```elixir
# In migration - add database constraint
create constraint(:products, :price_must_be_positive, check: "price > 0")

# In schema - handle constraint violation
def changeset(product, attrs) do
  product
  |> cast(attrs, [:price])
  |> validate_number(:price, greater_than: 0)
  |> check_constraint(:price, name: :price_must_be_positive,
       message: "must be greater than 0")
end
```

## Checklist

Before marking complete:

- [ ] Context has clear, single responsibility
- [ ] Schema has all required fields and associations
- [ ] Migration includes indices and constraints
- [ ] Changeset validations comprehensive
- [ ] Public API functions documented with @doc
- [ ] Return types documented with @spec (or dialyzer infers correctly)
- [ ] All functions return `{:ok, result}` or `{:error, reason}` tuples
- [ ] Tests cover CRUD operations
- [ ] Tests cover validations and constraints
- [ ] Tests cover edge cases
- [ ] Migration ran successfully
- [ ] No N+1 queries in common use cases
- [ ] Context follows existing patterns in codebase

## Next Steps

After creating context:
1. Run `mix test` to verify all tests pass
2. Run `mix ecto.migrate` to apply migration
3. Update router/controllers to use new context
4. Document context API in README or guides
5. Consider adding to project's architecture documentation
