# Contributing to BmadElixir

First off, thank you for considering contributing to BmadElixir! It's people like you that make this package better for the Elixir community.

## Code of Conduct

This project adheres to the Contributor Covenant [Code of Conduct](https://hex.pm/policies/codeofconduct). By participating, you are expected to uphold this code.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the existing issues to avoid duplicates. When you create a bug report, include as many details as possible:

- **Use a clear and descriptive title**
- **Describe the exact steps to reproduce the problem**
- **Provide specific examples** (code snippets, screenshots, etc.)
- **Describe the behavior you observed** and what you expected to see
- **Include your environment details** (Elixir version, OTP version, OS)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description** of the suggested enhancement
- **Explain why this enhancement would be useful** to users
- **Provide specific examples** to demonstrate the enhancement

### Contributing Code

1. **Fork the repository** and create your branch from `master`
2. **Follow the existing code style** - run `mix format` before committing
3. **Write tests** - all new code should have comprehensive ExUnit tests
4. **Ensure the test suite passes** - run `mix test`
5. **Run quality checks** - run `mix precommit` (format, credo, dialyzer, tests)
6. **Write a good commit message** - follow conventional commits style

### Pull Request Process

1. Update the README.md with details of changes if applicable
2. Update the CHANGELOG.md following [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) format
3. Ensure all quality checks pass (format, credo, dialyzer, tests)
4. The PR will be merged once you have approval from a maintainer

### Adding New Agents, Workflows, or Skills

When contributing new agents, workflows, or Claude Code skills:

1. **Agents** (`priv/agents/`) - Should follow the established pattern and include comprehensive examples
2. **Workflows** (`priv/workflows/`) - Should be practical, battle-tested workflows in YAML format
3. **Skills** (`priv/skills/`) - Should have clear triggers, examples, and YAML frontmatter
4. **Documentation** - All new features should be well-documented with examples

### Style Guidelines

#### Elixir Code Style

- Follow the [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- Run `mix format` before committing
- Ensure `mix credo --strict` passes
- Ensure `mix dialyzer` passes with zero errors
- Write comprehensive `@doc` and `@moduledoc` documentation

#### Markdown Style

- Use ATX-style headers (`#` not underlines)
- Use fenced code blocks with language identifiers
- Wrap lines at 80 characters for narrative text
- Use meaningful link text (not "click here")

#### Commit Messages

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
type(scope): subject

body

footer
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Example:
```
feat(skills): add elixir-performance-optimization skill

Add new Claude Code skill for identifying and fixing performance
bottlenecks in Elixir code. Includes patterns for N+1 queries,
GenServer bottlenecks, and inefficient Enum operations.

Closes #42
```

## Quality Standards

All contributions must meet these quality standards:

- ✅ `mix format --check-formatted` - All code formatted
- ✅ `mix compile --warnings-as-errors` - Zero compiler warnings
- ✅ `mix credo --strict` - No Credo issues
- ✅ `mix dialyzer` - Zero Dialyzer errors
- ✅ `mix test` - All tests passing
- ✅ Comprehensive documentation
- ✅ CHANGELOG.md updated

Run all checks at once:
```bash
mix precommit
```

## Attribution

Contributors will be acknowledged in:
- CHANGELOG.md for their specific contributions
- GitHub contributors page
- Release notes when applicable

## Questions?

Feel free to open an issue with the `question` label if you have any questions about contributing.

Thank you for contributing to BmadElixir! 🎉
