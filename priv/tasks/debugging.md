# Task: Debug Elixir/Phoenix Application

**Purpose**: Systematically diagnose and fix issues in Elixir/Phoenix applications

**Agent**: elixir-dev

**Duration**: 30 minutes - 4 hours (varies by issue complexity)

## Overview

Effective debugging in Elixir requires understanding the BEAM, OTP supervision trees, and Phoenix request lifecycle. Use systematic approaches to isolate and fix issues.

## Debugging Tools & Techniques

### 1. IEx - Interactive Elixir Shell

**Starting IEx:**
```bash
# With Mix project
iex -S mix

# With Phoenix server
iex -S mix phx.server

# Attach to running node
iex --sname debug --remsh my_app@localhost
```

**Key IEx Commands:**
```elixir
# Help
h()                          # General help
h(Enum.map)                  # Function documentation
i(variable)                  # Inspect value and type

# Recompile
recompile()                  # Recompile changed modules

# Process inspection
Process.list()               # All processes
Process.info(pid)            # Process details
:sys.get_state(pid)          # GenServer state (test/debug only!)

# History
v()                          # Last value
v(3)                         # Value from line 3

# Exit
Ctrl+C, Ctrl+C               # Exit IEx
```

### 2. IO.inspect - Print Debugging

**Basic Usage:**
```elixir
def process_data(data) do
  data
  |> transform()
  |> IO.inspect(label: "After transform")
  |> validate()
  |> IO.inspect(label: "After validate")
  |> save()
end
```

**Advanced Options:**
```elixir
# Limit output
IO.inspect(large_list, limit: 10)

# Pretty print
IO.inspect(struct, pretty: true)

# Custom label with function
data
|> IO.inspect(label: "Step 1")
|> Enum.map(&transform/1)
|> IO.inspect(label: "Step 2", limit: 5)
```

### 3. Logger - Application Logging

**Log Levels:**
```elixir
require Logger

Logger.debug("Detailed information for debugging")
Logger.info("General information about system operation")
Logger.warning("Warning messages")
Logger.error("Error messages")

# With metadata
Logger.info("User logged in",
  user_id: user.id,
  ip_address: conn.remote_ip
)
```

**Configure Logging:**
```elixir
# config/dev.exs
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id, :user_id]

# Log all SQL queries
config :my_app, MyApp.Repo,
  log: :debug  # Or false to disable
```

### 4. Debugger - Step Through Code

**Using IEx.pry:**
```elixir
# Add to code
require IEx

def problematic_function(data) do
  result = transform(data)
  IEx.pry()  # Execution stops here
  validate(result)
end
```

**In IEx session:**
```elixir
# When pry() is hit:
respawn()                    # Continue execution
whereami()                   # Show current code location
# Access local variables directly
result
data
```

**Using :debugger (Erlang debugger):**
```elixir
# Start graphical debugger
:debugger.start()

# Interpret module
:int.ni(MyModule)

# Set breakpoint
:int.break(MyModule, line_number)
```

### 5. Observer - System Monitoring

**Start Observer:**
```bash
# In IEx
iex> :observer.start()
```

**What to Monitor:**
- **Applications Tab**: See all running applications
- **Processes Tab**: Find memory leaks, runaway processes
- **System Tab**: Overall BEAM health
- **Load Charts**: CPU, Memory, I/O usage
- **Trace Overview**: Trace function calls

### 6. Recon - Production Debugging

```elixir
# Add to mix.exs
{:recon, "~> 2.5"}

# Find memory hogs
:recon.proc_count(:memory, 10)

# Find busy processes
:recon.proc_count(:reductions, 10)

# Find processes with large mailboxes
:recon.proc_count(:message_queue_len, 10)

# Get process info
:recon.info(pid)
```

## Common Issues & Solutions

### Issue 1: N+1 Query Performance

**Symptoms:**
- Slow page loads
- Many database queries in logs
- Warnings about preloading

**Diagnosis:**
```elixir
# Enable query logging
config :my_app, MyApp.Repo,
  log: :debug

# Check logs for repeated queries
```

**Solution:**
```elixir
# Bad: N+1 query
users = Repo.all(User)
Enum.each(users, fn user ->
  Enum.each(user.posts, fn post ->  # Query for each user!
    IO.puts post.title
  end)
end)

# Good: Preload
users = Repo.all(User) |> Repo.preload(:posts)
Enum.each(users, fn user ->
  Enum.each(user.posts, fn post ->  # Already loaded!
    IO.puts post.title
  end)
end)
```

### Issue 2: GenServer Crashes

**Symptoms:**
- Process exits unexpectedly
- Supervisor restart messages in logs

**Diagnosis:**
```elixir
# Check supervisor logs
Logger.error "GenServer #{inspect(self())} terminating"

# Get crash report
:sys.get_state(pid)  # If process still alive
Process.info(pid, :current_stacktrace)

# Check supervision tree
Supervisor.which_children(MySupervisor)
```

**Solution:**
```elixir
# Add better error handling
def handle_call(:risky_operation, _from, state) do
  try do
    result = perform_risky_operation(state)
    {:reply, {:ok, result}, state}
  rescue
    error ->
      Logger.error("Operation failed: #{inspect(error)}")
      {:reply, {:error, :operation_failed}, state}
  end
end

# Or use with for cleaner error handling
def handle_call(:risky_operation, _from, state) do
  with {:ok, data} <- fetch_data(state),
       {:ok, processed} <- process_data(data),
       {:ok, result} <- save_result(processed) do
    {:reply, {:ok, result}, state}
  else
    {:error, reason} = error ->
      Logger.error("Operation failed: #{inspect(reason)}")
      {:reply, error, state}
  end
end
```

### Issue 3: Memory Leaks

**Symptoms:**
- Memory usage grows over time
- Eventually crashes with :out_of_memory

**Diagnosis:**
```elixir
# In production (with recon)
:recon.proc_count(:memory, 10)

# Check for large ETS tables
:ets.all()
|> Enum.map(fn table ->
  {table, :ets.info(table, :size), :ets.info(table, :memory)}
end)
|> Enum.sort_by(fn {_, _, mem} -> mem end, :desc)

# Check LiveView assigns
# Look for large assigns, especially collections stored as lists
```

**Solution:**
```elixir
# Bad: Storing large collection in socket assigns
def mount(_params, _session, socket) do
  {:ok, assign(socket, :products, list_all_products())}  # Memory bloat!
end

# Good: Use streams
def mount(_params, _session, socket) do
  {:ok, stream(socket, :products, list_all_products())}
end

# Bad: Accumulating data in GenServer state
def handle_info({:log_event, event}, state) do
  new_events = [event | state.events]  # Grows forever!
  {:noreply, %{state | events: new_events}}
end

# Good: Limit size or use external storage
def handle_info({:log_event, event}, state) do
  new_events =
    [event | state.events]
    |> Enum.take(1000)  # Keep only last 1000

  {:noreply, %{state | events: new_events}}
end
```

### Issue 4: LiveView Not Updating

**Symptoms:**
- UI doesn't update after handle_event
- PubSub messages not received
- Stale data displayed

**Diagnosis:**
```elixir
# Check if socket connected
def mount(_params, _session, socket) do
  IO.inspect(connected?(socket), label: "Connected?")
  # ...
end

# Verify PubSub subscription
Phoenix.PubSub.subscribers(MyApp.PubSub, "topic_name")

# Check handle_info return value
def handle_info(msg, socket) do
  IO.inspect(msg, label: "Received message")
  {:noreply, socket}  # Did you forget to update socket?
end
```

**Solution:**
```elixir
# Ensure returning updated socket
def handle_event("delete", %{"id" => id}, socket) do
  product = get_product!(id)
  delete_product(product)

  # Must return updated socket!
  {:noreply, stream_delete(socket, :products, product)}
end

# Subscribe only when connected
def mount(_params, _session, socket) do
  if connected?(socket) do
    Phoenix.PubSub.subscribe(MyApp.PubSub, "products")
  end

  {:ok, stream(socket, :products, list_products())}
end
```

### Issue 5: Ecto Query Errors

**Symptoms:**
- Ecto.Query.CastError
- Association not loaded errors
- Invalid query errors

**Diagnosis:**
```elixir
# See generated SQL
query = from(u in User, where: u.active == true)
IO.inspect(Repo.to_sql(:all, query), label: "SQL")

# Check what was preloaded
user = Repo.get!(User, 1)
IO.inspect(Ecto.assoc_loaded?(user.posts), label: "Posts loaded?")
```

**Solution:**
```elixir
# Preload associations
user = Repo.get!(User, id) |> Repo.preload(:posts)

# Or in query
query = from(u in User, where: u.id == ^id, preload: [:posts])
Repo.one(query)

# For conditional preloading
query =
  from(u in User, where: u.id == ^id)
  |> maybe_preload_posts(should_preload?)

defp maybe_preload_posts(query, true), do: preload(query, :posts)
defp maybe_preload_posts(query, false), do: query
```

### Issue 6: Test Failures

**Symptoms:**
- Flaky tests
- Tests pass individually but fail in suite
- Timing-dependent failures

**Diagnosis:**
```elixir
# Run single test
mix test test/my_test.exs:23

# Run with seed (reproduce flaky test)
mix test --seed 12345

# Run failed tests only
mix test --failed

# Run with trace
mix test --trace
```

**Solution:**
```elixir
# Fix async issues
use MyApp.DataCase, async: false  # If tests share state

# Proper async handling in tests
test "async operation completes" do
  send_async_message()

  # Bad: Race condition
  assert get_result() == :done

  # Good: Wait for message
  assert_receive {:done, result}, 1000
  assert result == :expected
end

# Sandbox mode for database tests
# Ensure test/test_helper.exs has:
Ecto.Adapters.SQL.Sandbox.mode(MyApp.Repo, :manual)
```

## Debugging Workflows

### Workflow 1: Phoenix Request/Response Issues

1. **Check router:**
   ```bash
   mix phx.routes | grep "/path"
   ```

2. **Enable request logging:**
   ```elixir
   # Add to endpoint
   plug Plug.Logger
   ```

3. **Add breakpoint in controller:**
   ```elixir
   def index(conn, params) do
     require IEx; IEx.pry()
     # ...
   end
   ```

4. **Check conn struct:**
   ```elixir
   IO.inspect(conn.assigns, label: "Assigns")
   IO.inspect(conn.params, label: "Params")
   IO.inspect(conn.private, label: "Private")
   ```

### Workflow 2: Background Job Failures

1. **Check job queue:**
   ```elixir
   # For Oban
   Oban.check_queue(:default)
   ```

2. **Look at failed jobs:**
   ```elixir
   # Query failed jobs
   from(j in Oban.Job, where: j.state == "discarded")
   |> Repo.all()
   ```

3. **Retry job manually:**
   ```elixir
   Oban.retry_job(job_id)
   ```

4. **Add instrumentation:**
   ```elixir
   def perform(%{args: args}) do
     Logger.info("Starting job", args: args)

     result = do_work(args)

     Logger.info("Job completed", result: result)
     result
   end
   ```

### Workflow 3: Production Issues

1. **Connect to production node:**
   ```bash
   # Via SSH or kubectl
   iex --remsh my_app@prod-server
   ```

2. **Check system health:**
   ```elixir
   :observer.start()  # If GUI available
   :recon.proc_count(:memory, 10)
   :recon.proc_count(:reductions, 10)
   ```

3. **Check application status:**
   ```elixir
   Application.started_applications()
   Supervisor.which_children(MyApp.Supervisor)
   ```

4. **Review logs:**
   ```elixir
   # Check recent errors
   Logger.warning("Investigating production issue")
   ```

## Debugging Checklist

When debugging an issue:

- [ ] Can you reproduce the issue consistently?
- [ ] What changed recently (code, config, dependencies)?
- [ ] Have you checked the logs?
- [ ] Have you added IO.inspect to trace execution?
- [ ] Does it happen in all environments or just one?
- [ ] Have you checked for N+1 queries?
- [ ] Have you verified socket/process state?
- [ ] Have you checked error messages carefully?
- [ ] Have you consulted documentation?
- [ ] Have you searched GitHub issues?

## Prevention Strategies

### Add Comprehensive Tests

```elixir
# Test error cases too!
test "handles invalid input" do
  assert {:error, _} = MyContext.create_item(%{invalid: "data"})
end
```

### Use Type Specs

```elixir
@spec process_data(String.t()) :: {:ok, result} | {:error, term()}
      when result: map()
def process_data(data) do
  # Dialyzer will catch type errors
end
```

### Add Telemetry

```elixir
:telemetry.execute(
  [:my_app, :operation, :start],
  %{system_time: System.system_time()},
  %{operation: :process_data}
)
```

### Use Pattern Matching

```elixir
# Explicit patterns catch errors early
def handle_response({:ok, %{"data" => data}}) do
  process(data)
end

def handle_response({:error, reason}) do
  Logger.error("Request failed: #{inspect(reason)}")
  {:error, :request_failed}
end
```

## Resources

- [Elixir Logger](https://hexdocs.pm/logger)
- [IEx Documentation](https://hexdocs.pm/iex)
- [Observer Guide](https://www.erlang.org/doc/man/observer.html)
- [Recon Library](https://ferd.github.io/recon/)
- [Phoenix Debugging Guide](https://hexdocs.pm/phoenix/debugging.html)
- [Debugging with IEx.pry](https://blog.appsignal.com/2020/05/05/debugging-with-iex-pry-in-elixir.html)

## Next Steps

After fixing the issue:
1. Add test to prevent regression
2. Document the issue in comments/docs
3. Share learnings with team
4. Consider if similar issues exist elsewhere
5. Update error handling if needed
