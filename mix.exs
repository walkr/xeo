defmodule Xeo.MixProject do
  use Mix.Project

  def project do
    [
      app: :xeo,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:phoenix, ">= 0.0.0"},
      {:phoenix_html, ">= 0.0.0"},

      # Doc generation
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  defp package do
    [
      description:
        "Generate SEO, Open Graph and Twitter Cards HTML " <>
          "meta tags for Phoenix apps",
      maintainers: ["Tony Walker"],
      name: "xeo",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/walkr/xeo"},
      files: ~w(lib mix.exs LICENSE.md README.md CHANGELOG.md .formatter.exs)
    ]
  end

  def docs do
    [main: "readme", extras: ["README.md", "CHANGELOG.md"]]
  end
end
