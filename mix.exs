defmodule BmadElixir.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/yourusername/bmad_elixir"

  def project do
    [
      app: :bmad_elixir,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      name: "BmadElixir",
      source_url: @source_url,
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :eex]
    ]
  end

  defp deps do
    [
      {:yaml_elixir, "~> 2.9"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    BMAD-METHOD for Elixir/Phoenix - Agentic Agile Development framework providing
    specialized AI agents, workflows, and quality gates for Elixir and Phoenix projects.
    """
  end

  defp package do
    [
      name: "bmad_elixir",
      files: ~w(lib priv .formatter.exs mix.exs README.md LICENSE CHANGELOG.md),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "BMAD-METHOD" => "https://github.com/bmad-code-org/BMAD-METHOD"
      },
      maintainers: ["Your Name"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
