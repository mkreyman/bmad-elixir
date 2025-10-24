# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-01-23

### Added

#### Core Infrastructure
- Mix task `mix bmad.init` to initialize BMAD structure in Elixir/Phoenix projects
- Support for `--hooks` flag to install git pre-commit hooks
- Support for `--skills` flag to install Claude Code skills
- Support for `--force` flag to overwrite existing files
- Project configuration via `.bmad/config.yaml`

#### AI Agents
- **elixir-dev** - Senior Elixir/Phoenix Engineer for feature implementation
- **elixir-qa** - Quality Assurance specialist for testing and validation
- **elixir-architect** - System architect for OTP design and supervision trees
- **elixir-sm** - Scrum Master for story creation and workflow management
- **phoenix-expert** - Phoenix framework specialist (Controllers, LiveView, Channels)
- **ecto-specialist** - Database expert for schemas, migrations, and queries
- **elixir-release-manager** - Release preparation and deployment
- **elixir-documentation-specialist** - Documentation and ExDoc expert

#### Workflows
- **greenfield-phoenix** - Complete new Phoenix project setup
- **add-phoenix-context** - Create new bounded context
- **add-liveview-feature** - Implement LiveView feature

#### Quality Checklists
- **phoenix-checklist** - Phoenix best practices
- **ecto-checklist** - Database best practices
- **liveview-checklist** - LiveView best practices

#### Task Guides
- **create-story** - User story creation with acceptance criteria
- **qa-gate** - Quality validation (tests, credo, dialyzer, format)
- **write-tests** - Comprehensive testing strategies
- **create-context** - Phoenix context with Ecto patterns
- **create-liveview** - LiveView following best practices
- **debugging** - Debug workflows and tools (IEx, Observer, Recon)

#### Git Hooks
- **pre-commit** - Runs `mix precommit` (format, credo, dialyzer, test)
- **commit-msg** - Blocks Claude Code attributions, enforces message format
- **prepare-commit-msg** - Shows commit message guidelines
- **post-checkout** - Reminds about migrations when switching branches
- **post-merge** - Reminds about migrations after merges

#### Claude Code Skills

**Workflow Skills:**
- **elixir-quality-gate** - Run comprehensive quality checks (format, credo, dialyzer, tests)
- **phoenix-generator** - Guide Phoenix resource generation with best practices
- **ecto-migration-helper** - Create and manage Ecto migrations safely
- **elixir-test-runner** - Run ExUnit tests with smart filtering and debugging
- **phoenix-context-creator** - Create well-designed Phoenix contexts

**Enforcement Skills** (adapted from obra/superpowers):
- **elixir-discipline** - Master enforcement skill with mandatory pre-response checklist
- **elixir-tdd-enforcement** - RED-GREEN-REFACTOR cycle enforcement, no code without failing test first
- **elixir-no-shortcuts** - Prevent modifying ignore files (dialyzer.ignore, .credo.exs), enforce fixing actual problems
- **elixir-verification-gate** - Evidence before claims, run actual commands before claiming anything works
- **elixir-root-cause-only** - Systematic debugging with 4-phase process (Reproduce → Trace → Fix → Verify)
- **elixir-no-placeholders** - Prohibit placeholder code and default values for required data, enforce fail-loud/fail-fast

#### CI/CD
- GitHub Actions workflow with quality checks, multi-version testing, and Dialyzer
- Caching strategy for dependencies and PLT files
- Multi-version testing (Elixir 1.14-1.16, OTP 25-26)

#### Documentation
- Comprehensive README with installation, usage, and examples
- MIT License
- Quality enforcement documentation in all skills

## [Unreleased]

### Planned Features
- Advanced workflows for umbrella apps (v0.2.0)
- Integration with CI/CD pipelines (v0.3.0)
- Brownfield project support (v0.4.0)
- LiveView-specific workflows and agents (v0.5.0)

[0.1.0]: https://github.com/mkreyman/bmad-elixir/releases/tag/v0.1.0
