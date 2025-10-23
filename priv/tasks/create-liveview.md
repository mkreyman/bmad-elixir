# Task: Create LiveView Feature

**Purpose**: Implement interactive, real-time feature with Phoenix LiveView

**Agent**: elixir-dev

**Duration**: 2-6 hours (depending on complexity)

## Overview

LiveView enables rich, real-time user experiences without writing JavaScript. Follow established patterns from AGENTS.md and the LiveView checklist.

## Prerequisites

- Context and schemas already exist
- Understanding of LiveView lifecycle (mount, handle_event, handle_info)
- Familiarity with streams (not assigns) for collections

## Step 1: Plan LiveView Structure

**Duration**: 30 minutes

Answer these questions:

**State Management:**
- What data needs to be in socket assigns?
- What should be computed vs stored?
- Will we use streams for collections? (Answer: YES for all collections)

**User Interactions:**
- What buttons/forms will trigger events?
- What phx-* attributes needed?
- Will forms use live validation?

**Real-Time Updates:**
- Will this need PubSub for cross-user updates?
- What events should trigger broadcasts?
- How should optimistic UI work?

**Example Plan:**
```
Feature: Product Search & Management
Socket Assigns:
  - @search_query (string)
  - @selected_category (id or nil)
  - @form (for new/edit product)
Streams:
  - @streams.products (use streams, NOT assigns!)
Events:
  - "search" - Filter products
  - "select_category" - Filter by category
  - "delete" - Remove product
  - "save" - Create/update product
PubSub:
  - Subscribe to "products" topic
  - Broadcast on create/update/delete
```

## Step 2: Generate LiveView (Optional)

**Duration**: 5-10 minutes

```bash
# Full CRUD scaffold
mix phx.gen.live Catalog Product products name:string price:decimal sku:string

# Or create manually for more control
```

Generator creates:
- `lib/my_app_web/live/product_live/index.ex`
- `lib/my_app_web/live/product_live/show.ex`
- `lib/my_app_web/live/product_live/form_component.ex`
- Routes in router.ex

## Step 3: Implement Mount

**Duration**: 30 minutes - 1 hour

### Key Rules from AGENTS.md:
- Subscribe to PubSub **only when** `connected?(socket)`
- Use **streams** for collections, never assigns for lists
- Handle both connected and disconnected states

```elixir
defmodule MyAppWeb.ProductLive.Index do
  use MyAppWeb, :live_view

  alias MyApp.Catalog
  alias MyApp.Catalog.Product

  @impl true
  def mount(_params, _session, socket) do
    # PubSub subscription - ONLY when connected
    if connected?(socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "products")
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Products")
     |> assign(:search_query, "")
     |> assign(:selected_category, nil)
     |> stream(:products, Catalog.list_products())}
  end

  # Alternative with form
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Phoenix.PubSub.subscribe(MyApp.PubSub, "products")
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Products")
     |> assign(:search_query, "")
     |> stream(:products, Catalog.list_products())
     |> assign(:form, to_form(Catalog.change_product(%Product{})))}
  end
end
```

## Step 4: Implement Event Handlers

**Duration**: 1-2 hours

### Search/Filter Events

```elixir
@impl true
def handle_event("search", %{"search" => query}, socket) do
  products = Catalog.search_products(query)

  {:noreply,
   socket
   |> assign(:search_query, query)
   |> stream(:products, products, reset: true)}  # Reset stream with new results
end

@impl true
def handle_event("filter_category", %{"category_id" => category_id}, socket) do
  products = Catalog.list_products(filters: %{category_id: category_id})

  {:noreply,
   socket
   |> assign(:selected_category, category_id)
   |> stream(:products, products, reset: true)}
end

@impl true
def handle_event("clear_filters", _params, socket) do
  products = Catalog.list_products()

  {:noreply,
   socket
   |> assign(:search_query, "")
   |> assign(:selected_category, nil)
   |> stream(:products, products, reset: true)}
end
```

### Form Events (Following AGENTS.md Rules)

**CRITICAL: Always use `to_form/1`, never pass changeset to template!**

```elixir
@impl true
def handle_event("validate", %{"product" => product_params}, socket) do
  changeset =
    socket.assigns.product
    |> Catalog.change_product(product_params)
    |> Map.put(:action, :validate)

  # Use to_form/1 - NEVER pass changeset to template
  {:noreply, assign(socket, :form, to_form(changeset))}
end

@impl true
def handle_event("save", %{"product" => product_params}, socket) do
  case Catalog.create_product(product_params) do
    {:ok, product} ->
      {:noreply,
       socket
       |> put_flash(:info, "Product created successfully")
       |> stream_insert(:products, product, at: 0)}  # Prepend to stream

    {:error, %Ecto.Changeset{} = changeset} ->
      # Convert changeset to form
      {:noreply, assign(socket, :form, to_form(changeset))}
  end
end
```

### Delete Events

```elixir
@impl true
def handle_event("delete", %{"id" => id}, socket) do
  product = Catalog.get_product!(id)

  case Catalog.delete_product(product) do
    {:ok, _product} ->
      {:noreply,
       socket
       |> put_flash(:info, "Product deleted successfully")
       |> stream_delete(:products, product)}

    {:error, _changeset} ->
      {:noreply,
       socket
       |> put_flash(:error, "Could not delete product")}
  end
end
```

## Step 5: Implement PubSub Handlers

**Duration**: 30 minutes - 1 hour

Handle broadcasts from other processes/users:

```elixir
@impl true
def handle_info({:product_created, product}, socket) do
  # Another user created a product - prepend to stream
  {:noreply, stream_insert(socket, :products, product, at: 0)}
end

@impl true
def handle_info({:product_updated, product}, socket) do
  # Another user updated a product - update in stream
  {:noreply, stream_insert(socket, :products, product)}
end

@impl true
def handle_info({:product_deleted, product}, socket) do
  # Another user deleted a product - remove from stream
  {:noreply, stream_delete(socket, :products, product)}
end
```

## Step 6: Build Template

**Duration**: 1-2 hours

### Key Rules from AGENTS.md:
- Use `{...}` for attribute interpolation
- Use `<%= ... %>` for block constructs in body
- Use `:for` attribute, not `Enum.map`
- No `else if` - use `cond` instead
- Streams need `phx-update="stream"` and unique IDs

```heex
<.header>
  Listing Products
  <:actions>
    <.link patch={~p"/products/new"}>
      <.button>New Product</.button>
    </.link>
  </:actions>
</.header>

<%!-- Search Form with Debounce --%>
<.simple_form for={%{}} id="search-form" phx-change="search">
  <.input
    name="search"
    value={@search_query}
    placeholder="Search products..."
    phx-debounce="300"
  />
</.simple_form>

<%!-- Products Stream (CRITICAL: phx-update="stream" required!) --%>
<div id="products" phx-update="stream">
  <%!-- Empty State (using Tailwind's only: variant) --%>
  <div class="hidden only:block text-gray-500 text-center py-8">
    No products yet. Click "New Product" to add one.
  </div>

  <%!-- Product Items --%>
  <div
    :for={{id, product} <- @streams.products}
    id={id}
    class="border rounded-lg p-4 mb-2"
  >
    <div class="flex justify-between items-start">
      <div>
        <h3 class="font-bold">{product.name}</h3>
        <p class="text-gray-600">{product.description}</p>
        <p class="text-lg font-semibold">${product.price}</p>
      </div>
      <div class="flex gap-2">
        <.link patch={~p"/products/#{product}/edit"}>
          <.button>Edit</.button>
        </.link>
        <.button
          phx-click="delete"
          phx-value-id={product.id}
          data-confirm="Are you sure?"
        >
          Delete
        </.button>
      </div>
    </div>
  </div>
</div>

<%!-- Modal for New/Edit Product --%>
<.modal
  :if={@live_action in [:new, :edit]}
  id="product-modal"
  show
  on_cancel={JS.patch(~p"/products")}
>
  <.live_component
    module={MyAppWeb.ProductLive.FormComponent}
    id={@product.id || :new}
    title={@page_title}
    action={@live_action}
    product={@product}
    patch={~p"/products"}
  />
</.modal>
```

### Form Component Template

**CRITICAL: Use `<.form for={@form}>`, NOT `<.form for={@changeset}>`!**

```heex
<div>
  <.header>
    {@title}
  </.header>

  <%!-- Use @form, never @changeset in template --%>
  <.simple_form
    for={@form}
    id="product-form"
    phx-target={@myself}
    phx-change="validate"
    phx-submit="save"
  >
    <%!-- Use @form[:field], never @changeset[:field] --%>
    <.input field={@form[:name]} type="text" label="Name" />
    <.input field={@form[:description]} type="textarea" label="Description" />
    <.input field={@form[:price]} type="number" label="Price" step="0.01" />
    <.input field={@form[:sku]} type="text" label="SKU" />
    <.input field={@form[:quantity]} type="number" label="Quantity" />
    <.input field={@form[:active]} type="checkbox" label="Active" />

    <:actions>
      <.button phx-disable-with="Saving...">Save Product</.button>
    </:actions>
  </.simple_form>
</div>
```

## Step 7: Add LiveView Tests

**Duration**: 1-2 hours

See `write-tests.md` for comprehensive testing guide.

**Key Rules from AGENTS.md:**
- Always use element IDs in templates for testing
- Use `has_element?/2`, `element/2` - never test raw HTML
- Test against actual HTML output structure
- Use `LazyHTML` for debugging complex selectors

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

    test "saves new product", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/products")

      # Click New Product button
      assert index_live |> element("a", "New Product") |> render_click() =~
               "New Product"

      # Test validation
      assert index_live
             |> form("#product-form", product: %{name: "", price: "invalid"})
             |> render_change() =~ "can&#39;t be blank"

      # Submit form
      assert index_live
             |> form("#product-form",
               product: %{name: "Widget", price: "9.99", sku: "WID-001"}
             )
             |> render_submit()

      # Verify product appears (tests the stream update)
      assert_patch(index_live, ~p"/products")
      html = render(index_live)
      assert html =~ "Widget"
    end

    test "deletes product in listing", %{conn: conn} do
      product = product_fixture()
      {:ok, index_live, _html} = live(conn, ~p"/products")

      # Verify product exists
      assert has_element?(index_live, "#products-#{product.id}")

      # Delete product
      assert index_live
             |> element("#products-#{product.id} button", "Delete")
             |> render_click()

      # Verify product removed from stream
      refute has_element?(index_live, "#products-#{product.id}")
    end

    test "searches products", %{conn: conn} do
      widget = product_fixture(name: "Widget")
      _gadget = product_fixture(name: "Gadget")

      {:ok, index_live, _html} = live(conn, ~p"/products")

      # Search (with debounce)
      index_live
      |> element("#search-form")
      |> render_change(%{search: "widget"})

      html = render(index_live)
      assert html =~ "Widget"
      refute html =~ "Gadget"
    end
  end
end
```

## Step 8: Optimize Performance

**Duration**: 30 minutes

### Use Streams (NOT Assigns)

```elixir
# Bad: Storing list in assigns (memory bloat!)
assign(socket, :products, list_products())

# Good: Using streams (efficient!)
stream(socket, :products, list_products())
```

### Implement Debouncing

```heex
<%!-- Debounce search input --%>
<.input
  name="search"
  phx-debounce="300"
  placeholder="Search..."
/>
```

### Minimize Socket Assigns

```elixir
# Bad: Storing computed data
socket
|> assign(:products, products)
|> assign(:product_count, length(products))  # Redundant!
|> assign(:total_price, calculate_total(products))  # Expensive!

# Good: Only store what's needed, compute in template or LiveView
socket
|> stream(:products, products)
```

### Temporary Assigns

```elixir
# For one-time data, use temporary assigns
socket
|> assign(:flash_message, "Success!")
|> assign(:temp_data, large_data)  # Will be cleared after render
```

## Common Pitfalls (from AGENTS.md)

### ❌ Not Using Streams

```elixir
# WRONG - memory bloat with large lists
def mount(_params, _session, socket) do
  {:ok, assign(socket, :products, list_products())}
end

# CORRECT - use streams
def mount(_params, _session, socket) do
  {:ok, stream(socket, :products, list_products())}
end
```

### ❌ Missing phx-update="stream"

```heex
<%!-- WRONG - stream won't work without phx-update --%>
<div id="products">
  <div :for={{id, p} <- @streams.products} id={id}>...</div>
</div>

<%!-- CORRECT - has phx-update="stream" --%>
<div id="products" phx-update="stream">
  <div :for={{id, p} <- @streams.products} id={id}>...</div>
</div>
```

### ❌ Using Changeset in Template

```heex
<%!-- FORBIDDEN - never use @changeset in template! --%>
<.form for={@changeset} id="my-form">
  <.input field={@changeset[:name]} />
</.form>

<%!-- CORRECT - always use @form from to_form/1 --%>
<.form for={@form} id="my-form">
  <.input field={@form[:name]} />
</.form>
```

### ❌ Subscribing When Not Connected

```elixir
# WRONG - subscribes even on static render
def mount(_params, _session, socket) do
  Phoenix.PubSub.subscribe(MyApp.PubSub, "products")
  {:ok, socket}
end

# CORRECT - only subscribe when connected
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "products")
  end
  {:ok, socket}
end
```

### ❌ Using `else if` in HEEx

```heex
<%!-- INVALID - Elixir has no else if! --%>
<%= if @status == :active do %>
  Active
<% else if @status == :pending %>
  Pending
<% end %>

<%!-- CORRECT - use cond --%>
<%= cond do %>
  <% @status == :active -> %>
    Active
  <% @status == :pending -> %>
    Pending
  <% true -> %>
    Unknown
<% end %>
```

## Checklist

Before marking complete:

- [ ] Mount handles connected and disconnected states
- [ ] PubSub subscribed only when `connected?(socket)`
- [ ] All collections use streams (not assigns)
- [ ] Streams have `phx-update="stream"` in template
- [ ] Stream items have unique `id={id}` attribute
- [ ] Forms use `to_form/1` (never raw changeset in template)
- [ ] Forms use `<.input>` component from core_components
- [ ] Form validation implemented with phx-change="validate"
- [ ] Empty states handled (using Tailwind's `only:` variant)
- [ ] Event handlers return `{:noreply, socket}`
- [ ] PubSub handlers update UI correctly
- [ ] LiveView tests cover mount, events, and forms
- [ ] Real-time updates tested
- [ ] No `else if` in templates (use `cond`)
- [ ] Debouncing on search inputs
- [ ] Loading states shown (phx-disable-with)
- [ ] Unique DOM IDs on all interactive elements

## Next Steps

After completing LiveView:
1. Run `mix test` - verify all tests pass
2. Run LiveView in browser - test interactions
3. Test real-time updates with multiple browser tabs
4. Check for N+1 queries in logs
5. Monitor memory usage with large datasets
6. Document any LiveView-specific behavior
