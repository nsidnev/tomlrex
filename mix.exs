defmodule Tomlrex.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :tomlrex,
      version: @version,
      elixir: "~> 1.10",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      compilers: [:rustler] ++ Mix.compilers(),
      rustler_crates: rustler_crates(),
      deps: deps()
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  defp deps do
    [
      # core
      {:rustler, "~> 0.21.0"}
    ]
  end

  defp rustler_crates do
    [
      tomlrex: [
        path: "native/tomlrex",
        mode: rustc_mode(Mix.env())
      ]
    ]
  end

  defp rustc_mode(:prod), do: :release
  defp rustc_mode(_), do: :debug
end
