defmodule Mix.Tasks.Bmad.InitTest do
  use ExUnit.Case, async: false

  import ExUnit.CaptureIO

  @tmp_dir "tmp/test_project"

  setup do
    # Clean up before and after each test
    File.rm_rf!(@tmp_dir)
    File.mkdir_p!(@tmp_dir)

    # Change to tmp directory for test
    original_dir = File.cwd!()
    File.cd!(@tmp_dir)

    # Create a minimal git repo for hook tests
    System.cmd("git", ["init"], stderr_to_stdout: true)
    System.cmd("git", ["config", "user.email", "test@example.com"], stderr_to_stdout: true)
    System.cmd("git", ["config", "user.name", "Test User"], stderr_to_stdout: true)

    on_exit(fn ->
      File.cd!(original_dir)
      File.rm_rf!(@tmp_dir)
    end)

    :ok
  end

  describe "mix bmad.init" do
    test "creates directory structure" do
      capture_io(fn ->
        Mix.Tasks.Bmad.Init.run([])
      end)

      assert File.dir?(".bmad")
      assert File.dir?(".bmad/agents")
      assert File.dir?(".bmad/workflows")
      assert File.dir?(".bmad/tasks")
      assert File.dir?(".bmad/checklists")
      assert File.dir?("stories")
      assert File.dir?("stories/backlog")
      assert File.dir?("stories/in-progress")
      assert File.dir?("stories/completed")
    end

    test "creates config file" do
      capture_io(fn ->
        Mix.Tasks.Bmad.Init.run([])
      end)

      assert File.exists?(".bmad/config.yaml")

      config_content = File.read!(".bmad/config.yaml")
      assert config_content =~ "project:"
      assert config_content =~ "agents:"
      assert config_content =~ "workflows:"
      assert config_content =~ "quality:"
    end

    test "creates stories README" do
      capture_io(fn ->
        Mix.Tasks.Bmad.Init.run([])
      end)

      assert File.exists?("stories/README.md")

      readme = File.read!("stories/README.md")
      assert readme =~ "BMAD Stories"
      assert readme =~ "mix bmad.story"
    end

    test "outputs success message" do
      output =
        capture_io(fn ->
          Mix.Tasks.Bmad.Init.run([])
        end)

      assert output =~ "🚀 Initializing BMAD"
      assert output =~ "✅ BMAD initialization complete!"
      assert output =~ "Next steps:"
    end

    test "respects --force flag for config" do
      # First run
      capture_io(fn ->
        Mix.Tasks.Bmad.Init.run([])
      end)

      # Modify config
      File.write!(".bmad/config.yaml", "modified: true")

      # Run without --force (should not overwrite)
      output =
        capture_io(fn ->
          Mix.Tasks.Bmad.Init.run([])
        end)

      assert output =~ "Config already exists, skipping"
      assert File.read!(".bmad/config.yaml") == "modified: true"

      # Run with --force (should overwrite)
      capture_io(fn ->
        Mix.Tasks.Bmad.Init.run(["--force"])
      end)

      config = File.read!(".bmad/config.yaml")
      assert config =~ "project:"
      refute config =~ "modified: true"
    end

    @tag :skip
    test "installs git hooks when --hooks flag provided" do
      output =
        capture_io(fn ->
          Mix.Tasks.Bmad.Init.run(["--hooks"])
        end)

      assert output =~ "🎣 Installing git hooks"

      # Note: Hooks won't actually exist unless priv/hooks/ is available
      # This test is skipped because we don't have hooks in the package yet
    end

    test "handles non-git repository gracefully" do
      # Remove git directory
      File.rm_rf!(".git")

      output =
        capture_io(fn ->
          Mix.Tasks.Bmad.Init.run(["--hooks"])
        end)

      # Should not crash, just skip hooks
      assert output =~ "BMAD initialization complete"
    end
  end

  describe "directory structure" do
    test "creates all required subdirectories" do
      capture_io(fn ->
        Mix.Tasks.Bmad.Init.run([])
      end)

      required_dirs = [
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

      Enum.each(required_dirs, fn dir ->
        assert File.dir?(dir), "Expected directory #{dir} to exist"
      end)
    end
  end
end
