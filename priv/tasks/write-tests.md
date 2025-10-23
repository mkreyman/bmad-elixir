# Task: Write Comprehensive Tests

**Purpose**: Create thorough, maintainable test coverage for Elixir/Phoenix code

**Agent**: elixir-dev

**Duration**: 2-4 hours (depending on complexity)

## Overview

Comprehensive testing ensures code quality, prevents regressions, and documents expected behavior. Follow TDD principles: write tests first, see them fail, implement code, see them pass.

## Test Categories

### 1. Context Tests (Unit Tests)

Test business logic in isolation.

**File Location**: `test/my_app/context_name_test.exs`

**Example:**
```elixir
defmodule MyApp.AccountsTest do
  use MyApp.DataCase

  alias MyApp.Accounts

  describe "list_users/0" do
    test "returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "returns empty list when no users" do
      assert Accounts.list_users() == []
    end

    test "preloads associations when requested" do
      user = user_fixture()
      [loaded_user] = Accounts.list_users(preload: [:posts])
      assert Ecto.assoc_loaded?(loaded_user.posts)
    end
  end

  describe "get_user/1" do
    test "returns user when exists" do
      user = user_fixture()
      assert {:ok, found_user} = Accounts.get_user(user.id)
      assert found_user.id == user.id
    end

    test "returns error when not found" do
      assert {:error, :not_found} = Accounts.get_user(999)
    end
  end

  describe "create_user/1" do
    test "creates user with valid attributes" do
      attrs = %{email: "test@example.com", name: "Test User"}
      assert {:ok, %User{} = user} = Accounts.create_user(attrs)
      assert user.email == "test@example.com"
      assert user.name == "Test User"
    end

    test "returns error with invalid attributes" do
      attrs = %{email: "invalid", name: ""}
      assert {:error, %Ecto.Changeset{} = changeset} = Accounts.create_user(attrs)
      assert "is invalid" in errors_on(changeset).email
      assert "can't be blank" in errors_on(changeset).name
    end

    test "enforces unique email constraint" do
      user_fixture(email: "test@example.com")
      attrs = %{email: "test@example.com", name: "Another User"}

      assert {:error, changeset} = Accounts.create_user(attrs)
      assert "has already been taken" in errors_on(changeset).email
    end

    test "enforces foreign key constraint" do
      attrs = %{email: "test@example.com", name: "Test", organization_id: 999}

      assert {:error, changeset} = Accounts.create_user(attrs)
      assert "does not exist" in errors_on(changeset).organization_id
    end
  end

  describe "update_user/2" do
    test "updates user with valid attributes" do
      user = user_fixture()
      attrs = %{name: "Updated Name"}

      assert {:ok, updated_user} = Accounts.update_user(user, attrs)
      assert updated_user.name == "Updated Name"
      assert updated_user.email == user.email  # Unchanged
    end

    test "returns error with invalid attributes" do
      user = user_fixture()
      attrs = %{email: "invalid"}

      assert {:error, %Ecto.Changeset{}} = Accounts.update_user(user, attrs)
    end
  end

  describe "delete_user/1" do
    test "deletes the user" do
      user = user_fixture()

      assert {:ok, %User{}} = Accounts.delete_user(user)
      assert {:error, :not_found} = Accounts.get_user(user.id)
    end

    test "prevents deletion when user has associated records" do
      user = user_fixture()
      post_fixture(user: user)  # Creates associated post

      assert {:error, changeset} = Accounts.delete_user(user)
      assert "has associated records" in errors_on(changeset).base
    end
  end
end
```

### 2. LiveView Tests (Integration Tests)

Test UI interactions and real-time updates.

**File Location**: `test/my_app_web/live/resource_live_test.exs`

**Key Principles from AGENTS.md:**
- Use `Phoenix.LiveViewTest` and `LazyHTML` for assertions
- **Always** test against element IDs, not raw HTML
- Use `element/2`, `has_element?/2`, never test raw HTML strings
- Forms driven by `render_submit/2` and `render_change/2`
- Add unique DOM IDs to elements in templates for testing

**Example:**
```elixir
defmodule MyAppWeb.ProductLiveTest do
  use MyAppWeb.ConnCase

  import Phoenix.LiveViewTest
  import MyApp.CatalogFixtures

  describe "Index" do
    test "lists all products", %{conn: conn} do
      product = product_fixture()
      {:ok, _index_live, html} = live(conn, ~p"/products")

      assert html =~ "Listing Products"
      assert html =~ product.name
    end

    test "displays empty state when no products", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/products")

      # Test for empty state element (with Tailwind's only: class)
      assert html =~ "No products yet"
    end

    test "saves new product", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      # Click "New Product" button
      assert index_live
             |> element("a", "New Product")
             |> render_click() =~ "New Product"

      # Test form validation
      assert index_live
             |> form("#product-form", product: %{name: "", price: "invalid"})
             |> render_change() =~ "can&#39;t be blank"

      # Submit form
      assert index_live
             |> form("#product-form", product: %{name: "Widget", price: "9.99"})
             |> render_submit()

      # Verify redirect and new product appears
      assert_patch(index_live, ~p"/products")

      html = render(index_live)
      assert html =~ "Product created successfully"
      assert html =~ "Widget"
    end

    test "updates product in listing", %{conn: conn} do
      product = product_fixture()
      {:ok, index_live, _html} = live(conn, ~p"/products")

      # Click edit button (use ID for targeting)
      assert index_live
             |> element("#product-#{product.id} a", "Edit")
             |> render_click() =~ "Edit Product"

      # Update the product
      assert index_live
             |> form("#product-form", product: %{name: "Updated Widget"})
             |> render_submit()

      assert_patch(index_live, ~p"/products")

      html = render(index_live)
      assert html =~ "Product updated successfully"
      assert html =~ "Updated Widget"
    end

    test "deletes product in listing", %{conn: conn} do
      product = product_fixture()
      {:ok, index_live, _html} = live(conn, ~p"/products")

      # Click delete button
      assert index_live
             |> element("#product-#{product.id} button", "Delete")
             |> render_click()

      # Verify product no longer appears
      refute has_element?(index_live, "#product-#{product.id}")
    end

    test "filters products by search", %{conn: conn} do
      widget = product_fixture(name: "Widget")
      gadget = product_fixture(name: "Gadget")

      {:ok, index_live, _html} = live(conn, ~p"/products")

      # Search for "widget" (with debounce)
      index_live
      |> element("#search-form")
      |> render_change(%{search: "widget"})

      html = render(index_live)
      assert html =~ "Widget"
      refute html =~ "Gadget"
    end
  end

  describe "Show" do
    test "displays product", %{conn: conn} do
      product = product_fixture()
      {:ok, _show_live, html} = live(conn, ~p"/products/#{product.id}")

      assert html =~ "Show Product"
      assert html =~ product.name
    end

    test "updates product within modal", %{conn: conn} do
      product = product_fixture()
      {:ok, show_live, _html} = live(conn, ~p"/products/#{product.id}")

      # Open edit modal
      assert show_live
             |> element("a", "Edit")
             |> render_click() =~ "Edit Product"

      # Submit form
      assert show_live
             |> form("#product-form", product: %{name: "Updated"})
             |> render_submit()

      assert_patch(show_live, ~p"/products/#{product.id}")

      html = render(show_live)
      assert html =~ "Product updated successfully"
      assert html =~ "Updated"
    end
  end

  describe "Real-time updates" do
    test "receives updates when another user creates product", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      # Simulate another user creating product (triggers PubSub broadcast)
      product = product_fixture()

      # LiveView should receive and display the new product
      assert render(index_live) =~ product.name
    end

    test "receives updates when another user deletes product", %{conn: conn} do
      product = product_fixture()
      {:ok, index_live, _html} = live(conn, ~p"/products")

      # Verify product is displayed
      assert has_element?(index_live, "#product-#{product.id}")

      # Simulate another user deleting (triggers PubSub broadcast)
      Catalog.delete_product(product)

      # LiveView should remove the product
      refute has_element?(index_live, "#product-#{product.id}")
    end
  end
end
```

### 3. Controller Tests (API Tests)

Test API endpoints and JSON responses.

**File Location**: `test/my_app_web/controllers/resource_controller_test.exs`

**Example:**
```elixir
defmodule MyAppWeb.API.ProductControllerTest do
  use MyAppWeb.ConnCase

  import MyApp.CatalogFixtures

  @create_attrs %{name: "Widget", price: "9.99"}
  @invalid_attrs %{name: nil, price: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all products", %{conn: conn} do
      product = product_fixture()

      conn = get(conn, ~p"/api/products")

      assert json_response(conn, 200)["data"] == [
        %{
          "id" => product.id,
          "name" => product.name,
          "price" => "9.99"
        }
      ]
    end
  end

  describe "create product" do
    test "renders product when data is valid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @create_attrs)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{
        "id" => ^id,
        "name" => "Widget",
        "price" => "9.99"
      } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, ~p"/api/products", product: @invalid_attrs)

      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update product" do
    test "renders product when data is valid", %{conn: conn} do
      product = product_fixture()

      conn = put(conn, ~p"/api/products/#{product.id}", product: %{name: "Updated"})

      assert %{"id" => id} = json_response(conn, 200)["data"]

      conn = get(conn, ~p"/api/products/#{id}")

      assert %{"name" => "Updated"} = json_response(conn, 200)["data"]
    end
  end

  describe "delete product" do
    test "deletes chosen product", %{conn: conn} do
      product = product_fixture()

      conn = delete(conn, ~p"/api/products/#{product.id}")
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, ~p"/api/products/#{product.id}")
      end
    end
  end
end
```

### 4. Schema/Changeset Tests

Test validations and transformations.

**Example:**
```elixir
defmodule MyApp.Accounts.UserTest do
  use MyApp.DataCase

  alias MyApp.Accounts.User

  describe "changeset/2" do
    test "valid changeset with all required fields" do
      attrs = %{email: "test@example.com", name: "Test User"}
      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid?
    end

    test "invalid without email" do
      attrs = %{name: "Test User"}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).email
    end

    test "invalid with malformed email" do
      attrs = %{email: "invalid", name: "Test User"}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert "must have the @ sign" in errors_on(changeset).email
    end

    test "invalid with short name" do
      attrs = %{email: "test@example.com", name: "A"}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert "should be at least 2 character(s)" in errors_on(changeset).name
    end

    test "trims whitespace from name" do
      attrs = %{email: "test@example.com", name: "  Test User  "}
      changeset = User.changeset(%User{}, attrs)

      assert Ecto.Changeset.get_change(changeset, :name) == "Test User"
    end

    test "lowercases email" do
      attrs = %{email: "TEST@EXAMPLE.COM", name: "Test User"}
      changeset = User.changeset(%User{}, attrs)

      assert Ecto.Changeset.get_change(changeset, :email) == "test@example.com"
    end
  end
end
```

### 5. GenServer/Process Tests

Test concurrent processes and OTP behaviors.

**Example:**
```elixir
defmodule MyApp.Workers.NotificationWorkerTest do
  use MyApp.DataCase

  alias MyApp.Workers.NotificationWorker

  describe "start_link/1" do
    test "starts the worker" do
      assert {:ok, pid} = NotificationWorker.start_link(user_id: 123)
      assert Process.alive?(pid)
    end
  end

  describe "send_notification/2" do
    test "sends notification and updates state" do
      {:ok, pid} = NotificationWorker.start_link(user_id: 123)

      assert :ok = NotificationWorker.send_notification(pid, "Test message")

      # Use :sys.get_state for testing GenServer state (test-only)
      state = :sys.get_state(pid)
      assert state.sent_count == 1
    end

    test "handles concurrent notifications" do
      {:ok, pid} = NotificationWorker.start_link(user_id: 123)

      # Send multiple notifications concurrently
      tasks = for i <- 1..10 do
        Task.async(fn ->
          NotificationWorker.send_notification(pid, "Message #{i}")
        end)
      end

      # Wait for all to complete
      Enum.each(tasks, &Task.await/1)

      # Verify all processed
      state = :sys.get_state(pid)
      assert state.sent_count == 10
    end
  end

  describe "handle_info/2" do
    test "processes scheduled notifications" do
      {:ok, pid} = NotificationWorker.start_link(user_id: 123)

      # Send message directly to process
      send(pid, :send_scheduled)

      # Wait for processing
      :timer.sleep(100)

      state = :sys.get_state(pid)
      assert state.scheduled_sent == true
    end
  end
end
```

## Testing Best Practices

### Use Data Factories

**Never duplicate test data creation:**

```elixir
# test/support/fixtures/catalog_fixtures.ex
defmodule MyApp.CatalogFixtures do
  def product_fixture(attrs \\ %{}) do
    {:ok, product} =
      attrs
      |> Enum.into(%{
        name: "Test Product",
        price: Decimal.new("9.99"),
        sku: "TEST-#{System.unique_integer()}"
      })
      |> MyApp.Catalog.create_product()

    product
  end

  def product_with_category_fixture(attrs \\ %{}) do
    category = category_fixture()
    product_fixture(Map.put(attrs, :category_id, category.id))
  end
end
```

### Test Edge Cases

```elixir
describe "pagination" do
  test "returns first page" do
    # Create 25 products
    for i <- 1..25, do: product_fixture(name: "Product #{i}")

    assert {:ok, page} = Catalog.list_products(page: 1, per_page: 10)
    assert length(page.entries) == 10
    assert page.page_number == 1
    assert page.total_pages == 3
  end

  test "returns last page with remaining items" do
    for i <- 1..25, do: product_fixture(name: "Product #{i}")

    assert {:ok, page} = Catalog.list_products(page: 3, per_page: 10)
    assert length(page.entries) == 5  # Only 5 items on last page
  end

  test "returns empty page when page number too high" do
    assert {:ok, page} = Catalog.list_products(page: 999, per_page: 10)
    assert page.entries == []
  end
end
```

### Test Concurrent Access

```elixir
test "handles concurrent updates correctly" do
  product = product_fixture(quantity: 10)

  # Simulate 5 users purchasing concurrently
  tasks = for _ <- 1..5 do
    Task.async(fn ->
      Catalog.purchase_product(product.id, quantity: 2)
    end)
  end

  results = Enum.map(tasks, &Task.await/1)

  # All should succeed (optimistic locking)
  assert Enum.all?(results, &match?({:ok, _}, &1))

  # Final quantity should be 0
  assert Catalog.get_product!(product.id).quantity == 0
end
```

### Debug Failing Tests

When tests fail with element selectors:

```elixir
test "complex selector debugging", %{conn: conn} do
  {:ok, view, _html} = live(conn, ~p"/products")

  # Get the HTML
  html = render(view)

  # Parse with LazyHTML
  document = LazyHTML.from_fragment(html)

  # Test your selector
  matches = LazyHTML.filter(document, "#product-list .product-item")
  IO.inspect(matches, label: "Found Elements")

  # Now write proper assertion
  assert has_element?(view, "#product-list .product-item")
end
```

## Test Organization

### Group Related Tests

```elixir
describe "CRUD operations" do
  # All create/read/update/delete tests
end

describe "validations" do
  # All validation tests
end

describe "edge cases" do
  # Boundary conditions, error cases
end
```

### Use Setup Callbacks

```elixir
describe "authenticated user actions" do
  setup [:create_user, :log_in_user]

  test "can view dashboard", %{conn: conn} do
    conn = get(conn, ~p"/dashboard")
    assert html_response(conn, 200) =~ "Dashboard"
  end

  defp create_user(_context) do
    user = user_fixture()
    %{user: user}
  end

  defp log_in_user(%{conn: conn, user: user}) do
    %{conn: log_in_user(conn, user)}
  end
end
```

## Test Coverage

Run with coverage:
```bash
mix test --cover
```

Target: ≥ 80% coverage for new code

Check detailed coverage:
```bash
mix test --cover
open cover/excoveralls.html
```

## Common Pitfalls

### ❌ Testing Implementation Details
```elixir
# Bad: Testing internal state
test "increments counter" do
  {:ok, pid} = Worker.start_link()
  Worker.increment(pid)
  assert :sys.get_state(pid).counter == 1  # Too coupled to implementation
end

# Good: Testing behavior
test "emits event after increment" do
  {:ok, pid} = Worker.start_link()
  Worker.increment(pid)
  assert_receive {:counter_incremented, 1}
end
```

### ❌ Not Using Async
```elixir
# Bad: Sequential tests (slow)
use MyApp.DataCase

# Good: Parallel tests (fast)
use MyApp.DataCase, async: true
```

### ❌ Shared State Between Tests
```elixir
# Bad: Tests affect each other
@moduledoc "counter"
@counter 0  # Shared state!

test "increments", do: @counter = @counter + 1  # Affects other tests!

# Good: Each test isolated
test "increments" do
  counter = 0
  new_counter = counter + 1
  assert new_counter == 1
end
```

## Next Steps

After writing tests:
1. Run `mix test` - ensure all pass
2. Run `mix test --cover` - check coverage
3. Review test output for warnings
4. Commit tests with implementation
