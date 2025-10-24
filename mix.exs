defmodule BmadElixir.MixProject do
  use Mix.Project

  @version "0.1.1"
  @source_url "https://github.com/mkreyman/bmad-elixir"

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
      docs: docs(),
      aliases: aliases(),
      dialyzer: [
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        plt_add_apps: [:mix, :ex_unit]
      ]
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
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end

  def cli do
    [
      preferred_envs: [
        precommit: :test
      ]
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
      files: ~w(lib priv .formatter.exs mix.exs README.md LICENSE CHANGELOG.md CONTRIBUTING.md),
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "BMAD-METHOD" => "https://github.com/bmad-code-org/BMAD-METHOD"
      },
      maintainers: ["Mark Kreyman"]
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "CHANGELOG.md", "CONTRIBUTING.md"],
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp aliases do
    [
      precommit: [
        "format --check-formatted",
        "compile --warnings-as-errors",
        "credo --strict",
        "dialyzer",
        "test"
      ]
    ]
  end
end
