# Task: Create User Story

**Purpose**: Create well-structured user stories that guide development work

**Agent**: elixir-sm

**Duration**: 15-30 minutes

## Overview

User stories capture feature requirements from the user's perspective and break down work into manageable, testable units.

## Steps

### 1. Gather Requirements

**Questions to ask stakeholders:**
- Who is the user? (role, persona)
- What do they want to accomplish? (goal)
- Why do they need this? (value, business impact)
- What are the edge cases?
- What are the performance requirements?
- What are the security considerations?

### 2. Write Story in Standard Format

```
As a [role]
I want to [action]
So that [benefit]
```

**Example:**
```
As a customer
I want to search for available appointment slots
So that I can book an appointment at a convenient time
```

### 3. Define Acceptance Criteria

Write testable criteria using **Given-When-Then** format:

```
Given [initial context]
When [action occurs]
Then [expected outcome]
```

**Example:**
```
Given I am on the appointments page
When I search for slots on a specific date
Then I see all available time slots for that date
And the slots are sorted by time
And fully booked slots are not shown
```

### 4. Break Down into Technical Tasks

Identify implementation tasks:

**For Phoenix contexts:**
- [ ] Create context module (if new domain)
- [ ] Add schema and migration
- [ ] Implement context functions
- [ ] Write unit tests for context

**For LiveView features:**
- [ ] Create LiveView module
- [ ] Implement mount/handle_event
- [ ] Build template with streams
- [ ] Add LiveView tests

**For API endpoints:**
- [ ] Define routes
- [ ] Create controller action
- [ ] Add request validation
- [ ] Write controller tests

**For background jobs:**
- [ ] Create GenServer or Oban worker
- [ ] Implement business logic
- [ ] Add error handling
- [ ] Write process tests

### 5. Estimate Complexity

Use t-shirt sizing:
- **XS** (< 2 hours): Simple CRUD, minor UI changes
- **S** (2-4 hours): Single context feature, basic LiveView
- **M** (4-8 hours): Multiple context interactions, complex LiveView
- **L** (1-2 days): New bounded context, major architecture
- **XL** (2+ days): Break into smaller stories!

### 6. Identify Dependencies

Document:
- Required database migrations
- Dependencies on other stories
- External service integrations
- Infrastructure needs (PubSub, cache, etc.)

### 7. Add Non-Functional Requirements

Specify:
- **Performance**: Response time, query limits
- **Security**: Authorization, data validation
- **Scalability**: Expected load, concurrent users
- **Observability**: Logging, metrics, alerts

### 8. Create Story File

Save as `stories/STORY-###.md`:

```markdown
# STORY-123: Search Available Appointment Slots

**Status**: 📝 Ready for Development
**Size**: M (4-8 hours)
**Agent**: elixir-dev
**Priority**: High

## User Story

As a customer
I want to search for available appointment slots
So that I can book an appointment at a convenient time

## Acceptance Criteria

- [ ] Given I am on the appointments page
      When I search for slots on a specific date
      Then I see all available time slots for that date
      And the slots are sorted by time
      And fully booked slots are not shown

- [ ] Given I select a time slot
      When I click "Book Appointment"
      Then the slot is reserved for 10 minutes
      And I am redirected to the booking form

- [ ] Given no slots are available
      When I search for a date
      Then I see "No appointments available for this date"
      And I see a link to view the next available date

## Technical Tasks

- [ ] Create `Appointments.list_available_slots/2` function
- [ ] Add database query with proper indices
- [ ] Implement slot reservation logic with expiration
- [ ] Create `AppointmentLive.Search` LiveView
- [ ] Add real-time updates via PubSub when slots are booked
- [ ] Write comprehensive tests (context + LiveView)

## Dependencies

- STORY-120: Appointment schema must exist
- Database migration for slot reservation timestamps

## Non-Functional Requirements

**Performance:**
- Search query must complete in < 100ms
- Support 100 concurrent users searching

**Security:**
- Users can only see slots for their allowed locations
- Validate all date inputs to prevent injection

## Notes

- Slots refresh every 30 seconds via LiveView
- Consider caching available slots per location
- Monitor for N+1 queries in slot availability check
```

## Story Checklist

Before marking story as ready:

- [ ] User story follows "As a...I want...So that" format
- [ ] Acceptance criteria are specific and testable
- [ ] Technical tasks identified and scoped
- [ ] Size estimate provided
- [ ] Dependencies documented
- [ ] Non-functional requirements specified
- [ ] Edge cases considered
- [ ] Security implications reviewed

## Common Story Patterns

### CRUD Operation Story
```
As a [user]
I want to create/update/delete [resource]
So that I can manage [domain concept]

Tasks:
- Context function (create/update/delete)
- Schema and changeset validation
- Migration if new fields
- LiveView form or API endpoint
- Tests for happy path and errors
```

### Real-Time Feature Story
```
As a [user]
I want to see live updates when [event happens]
So that I have current information

Tasks:
- PubSub topic subscription in LiveView
- Broadcast after mutations in context
- handle_info for real-time updates
- Optimistic UI updates
- Tests with concurrent updates
```

### Background Processing Story
```
As a [user]
I want [system] to automatically [action]
So that I don't have to manually [task]

Tasks:
- Create GenServer or Oban job
- Implement business logic
- Schedule job (cron or trigger-based)
- Error handling and retries
- Monitoring and alerting
```

## Anti-Patterns to Avoid

❌ **Vague acceptance criteria**
```
"Search should work well" ← Not testable!
```
✅ **Specific acceptance criteria**
```
"Search returns results in < 100ms for up to 10,000 records"
```

❌ **Too large (epic-sized)**
```
"Build entire appointment booking system" ← Break it down!
```
✅ **Right-sized story**
```
"Add search for available appointment slots"
```

❌ **Technical task disguised as story**
```
"Add index to appointments table" ← This is a task, not a story
```
✅ **User-focused story**
```
"Speed up appointment search" ← User benefit clear
```

## Templates

### Feature Story Template
```markdown
# STORY-###: [Short Title]

**Status**: 📝 Ready / 🏗️ In Progress / ✅ Done
**Size**: XS/S/M/L/XL
**Agent**: elixir-dev/elixir-qa/elixir-architect
**Priority**: High/Medium/Low

## User Story
As a [role]
I want to [action]
So that [benefit]

## Acceptance Criteria
- [ ] Given...When...Then...

## Technical Tasks
- [ ] Task 1
- [ ] Task 2

## Dependencies
- STORY-###: Description

## Non-Functional Requirements
**Performance**: ...
**Security**: ...
```

### Bug Fix Story Template
```markdown
# STORY-###: Fix [Issue]

**Status**: 📝 Ready
**Size**: XS/S/M
**Agent**: elixir-dev
**Priority**: High (if production issue)

## Problem
Current behavior: ...
Expected behavior: ...
Error message/stack trace: ...

## Root Cause
[Analysis of why the bug exists]

## Solution
[How to fix it]

## Tasks
- [ ] Write failing test that reproduces bug
- [ ] Implement fix
- [ ] Verify all tests pass
- [ ] Deploy to staging and verify

## Prevention
[How to prevent similar bugs in the future]
```

## Next Steps

After creating story:
1. Review with team/stakeholders
2. Assign to appropriate agent (elixir-dev, elixir-architect, etc.)
3. Move to "Ready for Development" status
4. Track progress in story file
5. Run QA gate before marking complete
