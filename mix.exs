defmodule ExFabricators.Mixfile do
  use Mix.Project

  def project do
    [app: :ex_fabricators,
     version: "0.1.0",
     elixir: "~> 1.2",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps,
     description: description,
     package: package
   ]
  end

  def application do
    []
  end

  defp deps do
    []
  end

  defp description do
    """
    Easy way to cook your structs for tests
    """
  end

  defp package do
    [
      maintainers: ["Sergio Gernyak"],
      links: %{"GitHub" => "https://github.com/alterego-labs/ex_fabricators"}
    ]
  end
end
