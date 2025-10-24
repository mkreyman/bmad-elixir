defmodule BmadElixir do
  @moduledoc """
  BMAD-METHOD for Elixir/Phoenix - Agentic Agile Development Framework.

  BmadElixir provides specialized AI agents, workflows, and quality gates
  tailored for Elixir and Phoenix projects, following the BMAD-METHOD
  principles of agentic agile development.

  ## Installation

  Add `bmad_elixir` to your list of dependencies in `mix.exs`:

  ```elixir
  def deps do
    [
      {:bmad_elixir, "~> 0.1.0"}
    ]
  end
  ```

  ## Quick Start

  Initialize BMAD in your project:

  ```bash
  mix bmad.init
  ```

  This creates:
  - `.bmad/` directory with agents, workflows, tasks, and checklists
  - `stories/` directory for development stories
  - `.bmad/config.yaml` configuration file

  ## Features

  - **7 Specialized Agents**: Architecture, Development, QA, Story Management,
    Phoenix Expert, Ecto Specialist, Test Fixtures Specialist
  - **7 Workflows**: Greenfield Phoenix, API development, Background Jobs,
    Phoenix Channels, Test Fixtures, and more
  - **Quality Gates**: Pre-commit hooks, comprehensive checklists
  - **Story Management**: Track development stories from backlog to completion

  ## Mix Tasks

  - `mix bmad.init` - Initialize BMAD structure in your project
  - `mix bmad.init --hooks` - Initialize with git hooks
  - `mix bmad.init --force` - Overwrite existing files

  ## Documentation

  For comprehensive documentation, see:
  - [README](README.md)
  - [Agents on GitHub](https://github.com/mkreyman/bmad-elixir/tree/master/priv/agents)
  - [Workflows on GitHub](https://github.com/mkreyman/bmad-elixir/tree/master/priv/workflows)
  - [BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)
  """

  @doc """
  Returns the version of BmadElixir.

  ## Examples

      iex> BmadElixir.version()
      "0.1.1"

  """
  def version do
    Application.spec(:bmad_elixir, :vsn) |> to_string()
  end
end
