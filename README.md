# BmadElixir

> BMAD-METHOD for Elixir/Phoenix - Bring the power of Agentic Agile Development to your Elixir projects!

[![CI](https://github.com/mkreyman/bmad-elixir/actions/workflows/ci.yml/badge.svg)](https://github.com/mkreyman/bmad-elixir/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/mkreyman/bmad-elixir/blob/master/LICENSE)

Inspired by [BMAD-METHOD™](https://github.com/bmad-code-org/BMAD-METHOD), this package brings the proven Agentic Agile Development framework to Elixir and Phoenix projects with specialized AI agents, workflows, and quality gates tailored for the BEAM ecosystem.

## What is BMAD for Elixir?

BMAD (Breakthrough Method of Agile AI-Driven Development) provides:

- **🤖 Specialized AI Agents** - Expert agents for Elixir/Phoenix development (Dev, QA, Architect, SM)
- **📋 Development Workflows** - Proven workflows for Phoenix features, contexts, and LiveViews
- **✅ Quality Checklists** - Best practices for Elixir, Phoenix, Ecto, and LiveView
- **🎣 Git Hooks** - Automated quality enforcement with pre-commit, commit-msg, and post-merge hooks
- **📖 Story Management** - Structured approach to feature development with backlog, in-progress, and completed stories

## Quick Start

### Installation

Add `bmad_elixir` to your `mix.exs` dependencies:

```elixir
def deps do
  [
    {:bmad_elixir, "~> 0.1.0", only: :dev, runtime: false}
  ]
end
```

Then run:

```bash
mix deps.get
```

### Initialize BMAD in Your Project

```bash
# Basic initialization
mix bmad.init

# Initialize with git hooks
mix bmad.init --hooks
```

This creates:

```
your_phoenix_app/
├── .bmad/
│   ├── agents/           # AI agent definitions
│   ├── workflows/        # Development workflows
│   ├── tasks/            # Executable task guides
│   ├── checklists/       # Quality gate checklists
│   └── config.yaml       # Project configuration
└── stories/
    ├── backlog/          # Upcoming stories
    ├── in-progress/      # Active development
    └── completed/        # Done stories
```

## Available Agents

### Core Development Agents

- **elixir-dev** 💻 - Senior Elixir/Phoenix Engineer for feature implementation
- **elixir-qa** ✅ - Quality Assurance specialist for testing and validation
- **elixir-architect** 🏗️ - System architect for OTP design and supervision trees
- **elixir-sm** 📋 - Scrum Master for story creation and workflow management

### Specialized Agents

- **phoenix-expert** 🔥 - Phoenix framework specialist (Controllers, LiveView, Channels)
- **ecto-specialist** 🗄️ - Database expert for schemas, migrations, and queries
- **elixir-release-manager** 🚀 - Release preparation and deployment
- **elixir-documentation-specialist** 📝 - Documentation and ExDoc expert

## Usage

### Create a New Story

Copy and customize the story template:

```bash
cp .bmad/templates/story-template.yaml stories/STORY-001.yaml
```

Then edit `stories/STORY-001.yaml` with your story details.

### Use an Agent

Agents are markdown files that can be loaded into AI coding tools like Claude Code or GitHub Copilot. Each agent in `.bmad/agents/` contains:

- Role definition and responsibilities
- Commands and best practices
- Examples and patterns specific to that role

### Follow a Workflow

Workflows provide step-by-step guides for complex tasks. See `.bmad/workflows/` for available workflows:

- `greenfield-phoenix.yaml` - New Phoenix project setup
- `add-phoenix-context.yaml` - Create new bounded context
- `add-liveview-feature.yaml` - Implement LiveView feature

## Git Hooks

BMAD includes production-ready git hooks for quality enforcement:

- **pre-commit** - Runs `mix precommit` (format, credo, dialyzer, test)
- **commit-msg** - Blocks Claude Code attributions, enforces message format
- **prepare-commit-msg** - Shows commit message guidelines
- **post-checkout** - Reminds about migrations when switching branches
- **post-merge** - Reminds about migrations after merges

Install with:

```bash
mix bmad.init --hooks
```

## Claude Code Skills

BMAD includes Claude Code Skills - executable workflows that Claude Code automatically discovers and uses when appropriate.

### What Are Skills?

Skills are specialized capabilities that Claude Code loads on-demand based on your task. Unlike agents (which are comprehensive reference docs), skills are focused, executable workflows with specific triggers.

**Key Differences:**
- **Agents** (`.bmad/agents/`) - Comprehensive expertise you manually reference
- **Skills** (`.claude/skills/`) - Auto-invoked workflows Claude Code discovers

### Available Skills

**elixir-quality-gate**
- Runs comprehensive quality checks (format, credo, dialyzer, tests)
- Auto-triggers when validating code quality or before commits

**phoenix-generator**
- Guides using `mix phx.gen.*` commands with best practices
- Auto-triggers when creating Phoenix resources or schemas

**ecto-migration-helper**
- Creates and manages Ecto migrations safely
- Auto-triggers when working with database schema changes

**elixir-test-runner**
- Runs ExUnit tests with smart filtering and debugging
- Auto-triggers when running or debugging tests

**phoenix-context-creator**
- Creates well-designed Phoenix contexts following best practices
- Auto-triggers when designing new features or contexts

### Installation

```bash
# Install skills to .claude/skills/
mix bmad.init --skills

# Install both hooks and skills
mix bmad.init --hooks --skills
```

### How Skills Work

Skills use YAML frontmatter to declare when they should activate:

```yaml
---
name: elixir-quality-gate
description: Run comprehensive Elixir quality checks (format, credo, dialyzer, tests). Use when validating code quality or before commits.
---
```

When you ask Claude Code to "run quality checks," it automatically:
1. Reads skill descriptions
2. Identifies relevant skills
3. Loads and executes the appropriate workflow

### Project vs Personal Skills

**Project Skills** (`.claude/skills/`) - Shared with team via git:
```bash
mix bmad.init --skills  # Installs to .claude/skills/
git add .claude/skills/
```

**Personal Skills** (`~/.claude/skills/`) - Your personal toolkit:
```bash
cp -r .claude/skills/* ~/.claude/skills/
```

### Creating Custom Skills

See the installed skills as examples. Each skill is a directory containing:
- `SKILL.md` (required) - YAML frontmatter + instructions
- `scripts/` (optional) - Helper scripts
- `templates/` (optional) - Code templates

## Local Development

### Running Quality Checks

Run all quality checks locally before committing:

```bash
mix precommit
```

This runs:
1. **Format check** - `mix format --check-formatted`
2. **Compilation** - `mix compile --warnings-as-errors`
3. **Credo** - `mix credo --strict`
4. **Dialyzer** - `mix dialyzer` (type checking)
5. **Tests** - `mix test`

If you have git hooks installed, these checks run automatically on every commit.

### Individual Quality Checks

Run checks individually during development:

```bash
# Format code
mix format

# Static analysis
mix credo --strict

# Type checking (first run builds PLT - takes 1-2 minutes)
mix dialyzer

# Run tests
mix test
```

## CI/CD Pipeline

### GitHub Actions

This package includes a production-ready GitHub Actions workflow in `.github/workflows/ci.yml` that runs on every push and pull request.

#### Pipeline Jobs

1. **Quality Check** (runs once)
   - Code formatting validation
   - Compilation with warnings as errors
   - Credo static analysis (strict mode)

2. **Tests** (matrix: Elixir 1.14-1.16, OTP 25-26)
   - Runs test suite on multiple Elixir/OTP versions
   - Ensures compatibility across versions

3. **Dialyzer** (runs once)
   - Type checking with Dialyzer
   - PLT files cached for faster builds

#### Caching Strategy

The workflow includes intelligent caching:
- Dependencies (`deps/`, `_build/`)
- PLT files (`priv/plts/`) for faster Dialyzer runs

#### Multi-Version Testing

Tests run on:
- Elixir 1.16.0 + OTP 26.2
- Elixir 1.15.7 + OTP 25.3
- Elixir 1.14.5 + OTP 25.3

### Adding to Your Project

The workflow is installed when you run `mix bmad.init`. To use it in your Phoenix project:

1. Ensure `.github/workflows/ci.yml` exists
2. Ensure you have `mix.exs` with precommit alias configured
3. Push to GitHub - the workflow runs automatically

### Status Badges

Add CI status badges to your README:

```markdown
[![CI](https://github.com/yourusername/your_repo/actions/workflows/ci.yml/badge.svg)](https://github.com/yourusername/your_repo/actions/workflows/ci.yml)
```

## Configuration

Edit `.bmad/config.yaml` to customize:

```yaml
project:
  name: MyPhoenixApp
  type: elixir_phoenix

agents:
  default: elixir-dev
  available:
    - elixir-architect
    - elixir-dev
    - elixir-qa

quality:
  pre_commit:
    - mix format --check-formatted
    - mix credo --strict
    - mix dialyzer
    - mix test
```

## Example Workflow

1. **Create a story**: Copy template and fill in details
   ```bash
   cp .bmad/templates/story-template.yaml stories/STORY-042-oauth-login.yaml
   ```

2. **Review workflow**: Check `.bmad/workflows/` for relevant workflow guide

3. **Activate agent**: Load appropriate agent from `.bmad/agents/` (e.g., `elixir-dev.md`)

4. **Implement**: Follow story tasks, workflow steps, and established patterns

5. **Use task guides**: Reference `.bmad/tasks/` for detailed implementation help

6. **Test**: Write comprehensive ExUnit tests following TDD principles

7. **Quality check**: Pre-commit hook validates everything automatically

8. **Review checklists**: Verify against relevant checklists in `.bmad/checklists/`

9. **Complete**: Move story to completed folder when all criteria met

## What's Included

### 🤖 Four Core Agents

Located in `.bmad/agents/`:

1. **elixir-dev.md** - Senior Elixir/Phoenix Engineer
   - Feature implementation with TDD
   - Bug fixes and refactoring
   - Follows established patterns religiously

2. **elixir-qa.md** - Quality Assurance Specialist
   - Comprehensive test coverage
   - Quality gate validation (tests, credo, dialyzer)
   - Edge case discovery

3. **elixir-architect.md** - System Design Architect
   - OTP supervision trees
   - GenServer patterns
   - Phoenix context boundaries
   - Fault tolerance design

4. **elixir-sm.md** - Scrum Master
   - User story creation
   - Task breakdown
   - Agent coordination
   - Sprint planning

### 📋 Three Production Workflows

Located in `.bmad/workflows/`:

1. **greenfield-phoenix.yaml** - Complete new Phoenix project setup
   - Planning & Architecture (4-8 hours)
   - Project setup and configuration
   - Core infrastructure (auth, contexts, deployment)
   - Quality gates and best practices

2. **add-phoenix-context.yaml** - Systematic context creation (4-8 hours)
   - Context boundary definition
   - Schema and migration design
   - Context API implementation
   - Comprehensive testing

3. **add-liveview-feature.yaml** - LiveView implementation (4-8 hours)
   - LiveView structure planning
   - Mount, events, and PubSub handlers
   - Streams and forms (following AGENTS.md rules)
   - Performance optimization

### ✅ Three Quality Checklists

Located in `.bmad/checklists/`:

1. **phoenix-checklist.md** - Phoenix best practices
   - Context design and controllers
   - Security and performance
   - Error handling and testing
   - Deployment readiness

2. **ecto-checklist.md** - Database best practices
   - Schema design and associations
   - Migrations and indices
   - Query optimization
   - Multi-tenancy patterns

3. **liveview-checklist.md** - LiveView best practices
   - Lifecycle implementation
   - Streams and socket assigns
   - Forms and events
   - PubSub and real-time updates
   - Common pitfalls to avoid

### 📖 Six Task Guides

Located in `.bmad/tasks/`:

1. **create-story.md** - User story creation with acceptance criteria
2. **qa-gate.md** - Quality validation (tests, credo, dialyzer, format)
3. **write-tests.md** - Comprehensive testing strategies
4. **create-context.md** - Phoenix context with Ecto patterns
5. **create-liveview.md** - LiveView following best practices
6. **debugging.md** - Debug workflows and tools (IEx, Observer, Recon)

### 🔧 Five Git Hooks

Located in `priv/hooks/`:

1. **pre-commit.sh** - Quality checks and auto-restage
2. **commit-msg.sh** - Block AI attributions
3. **prepare-commit-msg.sh** - Show guidelines in editor
4. **post-checkout.sh** - Migration reminders
5. **post-merge.sh** - Dependency/migration alerts

### 📄 Two YAML Templates

Located in `.bmad/templates/`:

1. **story-template.yaml** - Comprehensive user story structure
2. **config-template.yaml** - BMAD configuration with all options

## Features

### 📋 Story-Driven Development

Stories provide structure and context using the YAML template:

```yaml
story:
  id: STORY-001
  title: "Add User Authentication"
  status: in_progress
  assigned_agent: elixir-dev

acceptance_criteria:
  - scenario: "User can register"
    given: "I am on the registration page"
    when: "I submit valid credentials"
    then:
      - "My account is created"
      - "I am logged in automatically"

technical_tasks:
  context:
    - "Create User schema with password hashing"
    - "Implement Accounts.create_user/1"
    - "Write comprehensive tests"
```

### 🎯 Quality Gates

Checklists ensure best practices:

- Phoenix controller patterns
- Ecto schema validations
- LiveView lifecycle hooks
- GenServer supervision
- Security considerations

### 🔄 Workflows

Guided workflows for common tasks:

- Creating new Phoenix contexts
- Implementing LiveView features
- Refactoring bounded contexts
- Adding Ecto migrations
- Security audits

## Inspired By

This package is inspired by and compatible with [BMAD-METHOD™](https://github.com/bmad-code-org/BMAD-METHOD), adapting its proven Agentic Agile Development approach for the Elixir/Phoenix ecosystem.

## Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

## License

MIT License - see [LICENSE](https://github.com/mkreyman/bmad-elixir/blob/master/LICENSE) for details.

## Roadmap

- [ ] v0.1.0 - Initial release with core agents and workflows
- [ ] v0.2.0 - Advanced workflows for umbrella apps
- [ ] v0.3.0 - Integration with CI/CD pipelines
- [ ] v0.4.0 - Brownfield project support
- [ ] v0.5.0 - LiveView-specific workflows and agents

## Resources

- [BMAD-METHOD™ Original](https://github.com/bmad-code-org/BMAD-METHOD)
- [Phoenix Framework](https://phoenixframework.org/)
- [Elixir Language](https://elixir-lang.org/)

---

Built with ❤️ for the Elixir community
