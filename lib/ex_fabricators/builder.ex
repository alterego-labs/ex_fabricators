defmodule ExFabricators.Builder do
  @moduledoc """
  Defines a fabricators builders.

  Builder provides a set of macroses for defining fabricators.
  Also provides functional for running fabricators.
  The result of building is a one or a bunch of structs.

  This builder can be useful in ExUnit tests when you need to prepare some structs as a
  income for a testable module function callings.

  For first you need to define a context in which you will define fabricators. For example, it
  may be `test/fabricators.ex`:

    defmodule Fabricators do
      use ExFabricators.Builder

      fabricator :team, YourApp.Structs.Team, %{}
    end

  Then in tests or in setup callbacks you can run fabricators like this:
    
    Fabricators.build :team

  As a result you give initialized `YourApp.Structs.Team` struct with default properties.

  If you try to build undefined fabricator `RuntimeError` will be thrown.
  """

  @doc false
  defmacro __using__(_) do
    quote do
      import ExFabricators.Builder, only: [fabricator: 3]

      def build(name) do
        build(name, %{})
      end

      @before_compile ExFabricators.Builder
    end
  end

  @doc """
  Generates a fabricator builder match based on its name.
  
  ## Examples:

    fabricator :team, YourApp.Structs.Team, %{}

  The last parameter is a Map with options. So, for example, if your Team struct has `id`
  property and you want to set it while building do it like the following:
    
    fabricator :team, YourApp.Structs.Team, %{id: 2}

  The you can provide some dependencies for the building structs:
    
    fabricator :event, YourApp.Structs.Event, %{home_team: Fabricators.build(:team)}
  """
  defmacro fabricator(name, struct, default_options) do
    quote do
      def build(unquote(name), options) do
        Kernel.struct(unquote(struct), unquote(default_options))
        |> Map.merge(options)
      end
    end
  end

  @doc false
  defmacro __before_compile__(env) do
    quote do
      def build(undefined_name, _options) do
        raise RuntimeError, "Undefined fabricator for '" <> Atom.to_string(undefined_name) <> "'!"
      end
    end
  end
end
