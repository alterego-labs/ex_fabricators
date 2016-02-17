defmodule ExFabricators.Builder do
  @moduledoc """
  Defines a fabricators builders.

  Builder provides a set of macroses for defining fabricators.
  Also provides functional for running fabricators.
  The result of building is a one or a bunch of structs.

  This builder can be useful in ExUnit tests when you need to prepare some structs as a
  income for a testable module function callings.

  For first you need to define a context in which you will define fabricators. For example, it
  may be `test/fabricators/team_fabricator.exs`:

    use ExFabricators.Builder

    fabricator :team, YourApp.Structs.Team

  Then in tests or in setup callbacks you can run fabricators like this:
    
    Fabricators.build(:team)

  As a result you give initialized `YourApp.Structs.Team` struct with default properties.

  If you try to build undefined fabricator `RuntimeError` will be thrown.
  """

  @typep fabricators :: Keyword.t

  @doc false
  defmacro __using__(_) do
    quote do
      import unquote(__MODULE__), only: [fabricator: 3, fabricator: 2]
      {:ok, agent} = ExFabricators.Builder.Agent.start_link()
      var!(builder_agent, ExFabricators.Builder) = agent
    end
  end

  @doc """
  Generates a fabricator builder match based on its name.
  
  ## Examples:

    fabricator :team, YourApp.Structs.Team

  The last parameter is a Map with options. So, for example, if your Team struct has `id`
  property and you want to set it while building do it like the following:
    
    fabricator :team, YourApp.Structs.Team, fn -> %{id: 2} end

  The you can provide some dependencies for the building structs:
    
    fabricator :event, YourApp.Structs.Event, fn -> %{home_team: Fabricators.build(:team)} end
  """
  defmacro fabricator(name, struct, default_options) do
    quote do
      ExFabricators.Builder.Agent.merge(
        var!(builder_agent, ExFabricators.Builder),
        [{unquote(name), {unquote(struct), unquote(default_options)}}]
      )
    end
  end

  defmacro fabricator(name, struct) do
    quote do
      ExFabricators.Builder.Agent.merge(
        var!(builder_agent, ExFabricators.Builder),
        [{unquote(name), {unquote(struct), fn -> %{} end}}]
      )
    end
  end

  @doc """
  Merges new fabricators entries into the registry.
  Also do validations for double entries with the same names.
  """
  @spec merge(fabricators, fabricators) :: fabricators | none
  def merge(registry, new_fabricators) do
    ExFabricators.validate!(registry, new_fabricators)
    Keyword.merge(registry, new_fabricators)   
  end
end
