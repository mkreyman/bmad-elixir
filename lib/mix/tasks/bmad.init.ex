defmodule Mix.Tasks.Bmad.Init do
  @moduledoc """
  Initialize BMAD structure in your Elixir/Phoenix project.

  ## Usage

      mix bmad.init
      mix bmad.init --hooks     # Also install git hooks
      mix bmad.init --force     # Overwrite existing files

  ## What this task does

  1. Creates `.bmad/` directory structure
  2. Copies AI agent definitions
  3. Copies workflow templates
  4. Copies task definitions
  5. Copies quality checklists
  6. Creates `stories/` directory for development stories
  7. Generates `.bmad/config.yaml` configuration
  8. Optionally installs git hooks for quality enforcement

  ## Directory Structure Created

      .bmad/
      ├── agents/           # AI agent definitions
      ├── workflows/        # Development workflows
      ├── tasks/            # Executable task definitions
      ├── checklists/       # Quality gate checklists
      └── config.yaml       # Project configuration

      stories/
      ├── backlog/          # Story backlog
      ├── in-progress/      # Active stories
      └── completed/        # Completed stories

  """

  use Mix.Task

  @shortdoc "Initialize BMAD structure in your project"

  @switches [
    hooks: :boolean,
    force: :boolean
  ]

  def run(args) do
    {opts, _} = OptionParser.parse!(args, strict: @switches)

    Mix.shell().info("🚀 Initializing BMAD for Elixir/Phoenix...")

    create_directory_structure()
    copy_agents()
    copy_workflows()
    copy_tasks()
    copy_checklists()
    create_config(opts)
    create_stories_structure()

    if opts[:hooks] do
      install_git_hooks(opts)
    end

    Mix.shell().info("")
    Mix.shell().info("✅ BMAD initialization complete!")
    Mix.shell().info("")
    Mix.shell().info("Next steps:")
    Mix.shell().info("  1. Review .bmad/config.yaml")
    Mix.shell().info("  2. Check out the agents in .bmad/agents/")
    Mix.shell().info("  3. Run `mix bmad.story new \"Your first story\"` to create a story")
    Mix.shell().info("  4. Use `mix bmad.agent list` to see available agents")
    Mix.shell().info("")
  end

  defp create_directory_structure do
    Mix.shell().info("📁 Creating directory structure...")

    dirs = [
      ".bmad",
      ".bmad/agents",
      ".bmad/workflows",
      ".bmad/tasks",
      ".bmad/checklists",
      "stories",
      "stories/backlog",
      "stories/in-progress",
      "stories/completed"
    ]

    Enum.each(dirs, &File.mkdir_p!/1)
  end

  defp copy_agents do
    Mix.shell().info("🤖 Installing AI agents...")

    priv_dir = :code.priv_dir(:bmad_elixir)
    agents_src = Path.join(priv_dir, "agents")
    agents_dest = ".bmad/agents"

    if File.exists?(agents_src) do
      File.cp_r!(agents_src, agents_dest)
      Mix.shell().info("   ✓ Copied agent definitions")
    else
      Mix.shell().info("   ⚠ Agent templates not found (this is expected during development)")
    end
  end

  defp copy_workflows do
    Mix.shell().info("🔄 Installing workflows...")

    priv_dir = :code.priv_dir(:bmad_elixir)
    workflows_src = Path.join(priv_dir, "workflows")
    workflows_dest = ".bmad/workflows"

    if File.exists?(workflows_src) do
      File.cp_r!(workflows_src, workflows_dest)
      Mix.shell().info("   ✓ Copied workflow templates")
    else
      Mix.shell().info("   ⚠ Workflow templates not found (this is expected during development)")
    end
  end

  defp copy_tasks do
    Mix.shell().info("📋 Installing tasks...")

    priv_dir = :code.priv_dir(:bmad_elixir)
    tasks_src = Path.join(priv_dir, "tasks")
    tasks_dest = ".bmad/tasks"

    if File.exists?(tasks_src) do
      File.cp_r!(tasks_src, tasks_dest)
      Mix.shell().info("   ✓ Copied task definitions")
    else
      Mix.shell().info("   ⚠ Task templates not found (this is expected during development)")
    end
  end

  defp copy_checklists do
    Mix.shell().info("✅ Installing checklists...")

    priv_dir = :code.priv_dir(:bmad_elixir)
    checklists_src = Path.join(priv_dir, "checklists")
    checklists_dest = ".bmad/checklists"

    if File.exists?(checklists_src) do
      File.cp_r!(checklists_src, checklists_dest)
      Mix.shell().info("   ✓ Copied quality checklists")
    else
      Mix.shell().info("   ⚠ Checklist templates not found (this is expected during development)")
    end
  end

  defp create_config(opts) do
    Mix.shell().info("⚙️  Creating configuration...")

    config_path = ".bmad/config.yaml"

    if File.exists?(config_path) and !opts[:force] do
      Mix.shell().info("   ⚠ Config already exists, skipping (use --force to overwrite)")
    else
      app_module =
        case Mix.Project.config()[:app] do
          nil -> "MyApp"
          app -> app |> to_string() |> Macro.camelize()
        end

      config_content = """
      # BMAD Configuration for #{app_module}
      project:
        name: #{app_module}
        type: elixir_phoenix
        version: 0.1.0

      agents:
        default: elixir-dev
        available:
          - elixir-architect
          - elixir-dev
          - elixir-qa
          - elixir-sm
          - phoenix-expert
          - ecto-specialist

      workflows:
        default: greenfield-phoenix

      quality:
        pre_commit:
          - mix format --check-formatted
          - mix credo --strict
          - mix dialyzer
          - mix test

      stories:
        template: story-tmpl.yaml
        backlog_dir: stories/backlog
        in_progress_dir: stories/in-progress
        completed_dir: stories/completed
      """

      File.write!(config_path, config_content)
      Mix.shell().info("   ✓ Created .bmad/config.yaml")
    end
  end

  defp create_stories_structure do
    Mix.shell().info("📖 Creating stories structure...")

    readme_content = """
    # BMAD Stories

    This directory contains development stories for your project.

    ## Structure

    - `backlog/` - Stories waiting to be worked on
    - `in-progress/` - Stories currently being developed
    - `completed/` - Finished stories (for reference)

    ## Usage

    Create a new story:
    ```bash
    mix bmad.story new "Add user authentication"
    ```

    Move a story to in-progress:
    ```bash
    mix bmad.story start backlog/STORY-001-user-auth.md
    ```

    Complete a story:
    ```bash
    mix bmad.story complete in-progress/STORY-001-user-auth.md
    ```
    """

    File.write!("stories/README.md", readme_content)
    Mix.shell().info("   ✓ Created stories/ structure")
  end

  defp install_git_hooks(opts) do
    Mix.shell().info("🎣 Installing git hooks...")

    priv_dir = :code.priv_dir(:bmad_elixir)
    hooks_src = Path.join(priv_dir, "hooks")

    if !File.exists?(".git") do
      Mix.shell().error("   ✗ Not a git repository, skipping hooks")
    else
      hooks_to_install = [
        "pre-commit",
        "commit-msg",
        "prepare-commit-msg",
        "post-checkout",
        "post-merge"
      ]

      Enum.each(hooks_to_install, fn hook_name ->
        src = Path.join(hooks_src, "#{hook_name}.sh")
        dest = Path.join(".git/hooks", hook_name)

        if File.exists?(src) do
          if File.exists?(dest) and !opts[:force] do
            Mix.shell().info(
              "   ⚠ #{hook_name} already exists, skipping (use --force to overwrite)"
            )
          else
            File.cp!(src, dest)
            File.chmod!(dest, 0o755)
            Mix.shell().info("   ✓ Installed #{hook_name}")
          end
        else
          Mix.shell().info("   ⚠ #{hook_name}.sh not found in package")
        end
      end)
    end
  end
end
