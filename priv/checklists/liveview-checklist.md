# LiveView Best Practices Checklist

Use this checklist when implementing Phoenix LiveView features to ensure best practices and avoid common pitfalls.

## Lifecycle Implementation

### Mount
- [ ] Handles both connected and disconnected states
- [ ] Subscribes to PubSub only when `connected?(socket)`
- [ ] Loads initial data efficiently
- [ ] Sets up all required assigns
- [ ] Uses streams for collections (not regular assigns)
- [ ] Returns `{:ok, socket}` or `{:ok, socket, options}`

### Handle Event
- [ ] All interactive elements have phx-* attributes
- [ ] Event names are descriptive ("save", "delete", not "click")
- [ ] Uses `phx-value-*` to pass event data
- [ ] Returns `{:noreply, socket}` after updates
- [ ] Provides user feedback (flash, UI updates)
- [ ] Handles errors gracefully

### Handle Info
- [ ] PubSub messages handled correctly
- [ ] Process messages handled correctly
- [ ] Updates UI based on messages
- [ ] Returns `{:noreply, socket}`

## Socket Assigns

### Minimizing Assigns
- [ ] Stores only what's needed for rendering
- [ ] Uses streams for all collections
- [ ] Avoids storing large data structures
- [ ] Removes assigns when no longer needed
- [ ] Uses temporary assigns for one-time data

### Naming
- [ ] Assign names are descriptive
- [ ] Boolean assigns end in `?` (e.g., `loading?`, `empty?`)
- [ ] Consistent naming across LiveViews
- [ ] No generic names like `data` or `info`

## Streams

### Usage
- [ ] All collections use streams (not assigns)
- [ ] Container has `phx-update="stream"` and unique `id`
- [ ] Stream items have unique `id` attribute: `<div id={id}>`
- [ ] Uses `stream/3` to add items
- [ ] Uses `stream_delete/3` to remove items
- [ ] Uses `stream_insert/4` with `at:` for positioning
- [ ] Reset with `stream/4` and `reset: true`

### Empty States
- [ ] Handles empty collections gracefully
- [ ] Uses Tailwind's `only:` variant for empty state message
- [ ] Provides clear message when no items exist

```elixir
<div id="products" phx-update="stream">
  <div class="hidden only:block">No products yet.</div>
  <div :for={{id, product} <- @streams.products} id={id}>
    ...
  </div>
</div>
```

## Forms

### Setup
- [ ] Uses `to_form/1` to create form struct
- [ ] Form has unique `id` attribute
- [ ] Implements `phx-change="validate"` for live validation
- [ ] Implements `phx-submit="save"` for submission
- [ ] Uses `<.input>` component from core_components

### Validation
- [ ] Validates on change with `action: :validate`
- [ ] Shows errors inline
- [ ] Disables submit button during processing
- [ ] Clears form after successful submit
- [ ] Provides clear success/error feedback

### Example
```elixir
<.form
  for={@form}
  id="product-form"
  phx-change="validate"
  phx-submit="save"
>
  <.input field={@form[:name]} label="Name" />
  <.input field={@form[:price]} label="Price" type="number" />
  <.button phx-disable-with="Saving...">Save</.button>
</.form>
```

## Events & Interactions

### Event Attributes
- [ ] Uses `phx-click` for clicks
- [ ] Uses `phx-submit` for form submissions
- [ ] Uses `phx-change` for form/input changes
- [ ] Uses `phx-value-*` to pass data
- [ ] Uses `phx-target` for component events
- [ ] Uses `phx-debounce` for search inputs

### User Feedback
- [ ] Shows loading states (`phx-disable-with`)
- [ ] Provides success messages (flash or inline)
- [ ] Shows error messages clearly
- [ ] Implements optimistic UI updates where appropriate
- [ ] Disables buttons during processing

## PubSub & Real-time

### Subscription
- [ ] Subscribes only when `connected?(socket)`
- [ ] Topic names are descriptive and scoped
- [ ] Unsubscribe is automatic on disconnect (no manual cleanup)
- [ ] Multiple subscriptions managed properly

### Broadcasting
- [ ] Broadcasts after successful mutations
- [ ] Includes all data needed for UI update
- [ ] Broadcasts to correct topic
- [ ] Handles broadcast failures gracefully

### Example
```elixir
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "products")
  end

  {:ok, stream(socket, :products, list_products())}
end

def handle_info({:product_created, product}, socket) do
  {:noreply, stream_insert(socket, :products, product, at: 0)}
end
```

## Performance

### Optimization
- [ ] Uses streams instead of assigns for collections
- [ ] Implements pagination for large datasets
- [ ] Uses `phx-debounce` on search/filter inputs
- [ ] Minimizes socket assigns
- [ ] Avoids expensive computations in templates
- [ ] Uses `phx-update="ignore"` for external JS

### Rendering
- [ ] No heavy computations in templates
- [ ] Conditional rendering with `:if` attribute
- [ ] Loops use `:for` attribute (not Enum.map)
- [ ] Components extract reusable markup
- [ ] CSS classes precomputed when possible

## Testing

### Mount Tests
- [ ] Tests initial render
- [ ] Tests data loading
- [ ] Tests empty states
- [ ] Tests error states
- [ ] Tests with different user permissions

### Event Tests
- [ ] Tests all phx-click handlers
- [ ] Tests form submissions
- [ ] Tests form validations
- [ ] Tests delete/update operations
- [ ] Tests edge cases

### Integration Tests
- [ ] Tests full user flows
- [ ] Tests real-time updates
- [ ] Tests concurrent users (if applicable)
- [ ] Tests navigation between LiveViews

## Security

### Authorization
- [ ] Checks user permissions in mount
- [ ] Validates access on every event
- [ ] No unauthorized data exposed in assigns
- [ ] Can't access other users' data
- [ ] Proper tenant isolation (if multi-tenant)

### Input Validation
- [ ] All event params validated
- [ ] Form data validated in changeset
- [ ] No raw HTML injection
- [ ] CSRF protection enabled (default in Phoenix)

## Component Organization

### LiveComponents
- [ ] Only used when state isolation needed
- [ ] Has unique `id` prop
- [ ] Updates via `send_update/2`
- [ ] Minimal coupling to parent

### Function Components
- [ ] Preferred over LiveComponents for stateless UI
- [ ] Props validated with `attr/3`
- [ ] Slots used for flexible content
- [ ] Reusable across LiveViews

## Common Patterns

### Filtering
```elixir
def handle_event("filter", %{"filter" => filter}, socket) do
  products = list_products(filter)

  {:noreply,
   socket
   |> assign(:filter, filter)
   |> stream(:products, products, reset: true)}
end
```

### Pagination
```elixir
def handle_event("load-more", _, socket) do
  page = socket.assigns.page + 1
  products = list_products(page: page)

  {:noreply,
   socket
   |> assign(:page, page)
   |> stream(:products, products)}
end
```

### Optimistic UI
```elixir
def handle_event("delete", %{"id" => id}, socket) do
  product = get_product!(id)

  # Optimistic update
  socket = stream_delete(socket, :products, product)

  # Async deletion
  Task.start(fn -> delete_product(product) end)

  {:noreply, socket}
end
```

## Common Pitfalls

❌ **Storing collections in assigns**
```elixir
# Bad - stores entire list in socket
assign(socket, :products, list_products())

# Good - uses stream
stream(socket, :products, list_products())
```

❌ **Subscribing when not connected**
```elixir
# Bad - subscribes even when not connected
def mount(_params, _session, socket) do
  Phoenix.PubSub.subscribe(MyApp.PubSub, "products")
  {:ok, socket}
end

# Good - only subscribe when connected
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "products")
  end
  {:ok, socket}
end
```

❌ **Missing phx-update="stream"**
```elixir
# Bad - missing phx-update
<div id="products">  <!-- Missing phx-update="stream" -->
  <div :for={{id, p} <- @streams.products} id={id}>...</div>
</div>

# Good - has phx-update
<div id="products" phx-update="stream">
  <div :for={{id, p} <- @streams.products} id={id}>...</div>
</div>
```

❌ **Not using to_form**
```elixir
# Bad - using changeset directly
<.form for={@changeset}>

# Good - using to_form
<.form for={@form}>  <!-- where @form = to_form(@changeset) -->
```

❌ **Heavy computations in templates**
```elixir
# Bad - expensive calculation in template
<%= Enum.map(@products, &expensive_calculation/1) %>

# Good - precompute in handle_event/mount
products_with_data = Enum.map(products, &expensive_calculation/1)
assign(socket, :products_with_data, products_with_data)
```

## Before Completing

- [ ] All events tested
- [ ] Real-time updates working
- [ ] Loading states implemented
- [ ] Error handling complete
- [ ] Performance acceptable
- [ ] No memory leaks (check socket assigns)
- [ ] Works with multiple concurrent users
- [ ] Proper authorization checks
- [ ] User feedback clear
- [ ] Edge cases handled
