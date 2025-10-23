# BmadElixir

> BMAD-METHOD for Elixir/Phoenix - Bring the power of Agentic Agile Development to your Elixir projects!

[![Hex.pm](https://img.shields.io/hexpm/v/bmad_elixir.svg)](https://hex.pm/packages/bmad_elixir)
[![Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/bmad_elixir/)
[![License](https://img.shields.io/hexpm/l/bmad_elixir.svg)](https://github.com/yourusername/bmad_elixir/blob/main/LICENSE)

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

```bash
mix bmad.story new "Add user authentication"
```

### List Available Agents

```bash
mix bmad.agent list
```

### Run a Workflow

```bash
mix bmad.workflow run greenfield-phoenix
```

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

1. **Create a story**: `mix bmad.story new "Add OAuth login"`
2. **Activate agent**: Load `elixir-dev` agent in your IDE
3. **Implement**: Follow the story tasks and established patterns
4. **Test**: Write comprehensive ExUnit tests
5. **Quality check**: Pre-commit hook validates everything
6. **Complete**: `mix bmad.story complete`

## Features

### 📋 Story-Driven Development

Stories provide structure and context:

```markdown
# STORY-001: Add User Authentication

## Tasks
- [x] Create User schema
- [x] Implement Auth context
- [x] Add password hashing
- [ ] Create session management
- [ ] Write comprehensive tests

## Implementation Notes
- Following existing pattern in Accounts context
- Using bcrypt for password hashing
- Tests: 15/15 passing
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

MIT License - see [LICENSE](LICENSE) for details.

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
