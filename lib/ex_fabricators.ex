defmodule ExFabricators do
  @moduledoc false

  alias ExFabricators.FabricatorsRepo

  @typep fabricators :: Keyword.t

  @doc """
  Runs the process to gathering all defined fabricators and provides them for to be able to build.

  So in `test/test_helper.exs` you must to add the next line:

    ExFabricators.take_all!(Path.join(File.cwd!, "test/fabricators"))
    
  """
  @spec take_all!(String.t) :: any
  def take_all!(fabricators_path) do
    fabricators_path
    |> fetch_and_merge_all_builders
    |> start_and_populate_agent
  end

  @doc """
  Entry points to run some specific fabricator with custom properties

  ## Examples
  
  Build some `Team` struct with default properties:

    ExFabricators.build(:team) # => %YourApp.Structs.Team{...}

  Build team with some custom properties:

    ExFabricators.build(:team, %{a: 1}) # => %YourApp.Structs.Team{a: 1, ...}
  """
  @spec build(:atom, map) :: struct
  def build(name, options \\ %{}) do
    FabricatorsRepo.get
    |> Keyword.get(name)
    |> instantiate_struct(options)
  end

  @doc """
  Validates new fabricators entries for doubling. So if there are some new entries with names that
  already contained in registry of fabricators RuntimeError will be raised.

  ## Examples

  When try to validate fully uniq new entries:

    ExFabricators.validate!([team: {..., ...}], [team1: {..., ...}] # => :ok

  When try to validate new entries that some one from them is not uniq:

    ExFabricators.validate!([team: {..., ...}], [team: {..., ...}]
    # => RuntimeError
  
  """
  @spec validate!(fabricators, fabricators) :: :ok | none
  def validate!(fabricators, new_fabricators) do
    new_fabricators
    |> Keyword.keys
    |> Enum.each(fn(key) ->
      if Keyword.has_key?(fabricators, key) do
        raise RuntimeError,
          "Fabricator for `#{Atom.to_string(key)}` already defined!"
      end
    end)
    :ok
  end

  defp fetch_and_merge_all_builders(fabricators_path) do
    fabricators_path
    |> Path.join("*_fabricator.exs")
    |> Path.wildcard
    |> Enum.map(&read_file!(&1))
    |> Enum.reduce([], fn(fabricators, acc) ->
      validate!(acc, fabricators)
      Keyword.merge(acc, fabricators)
    end)
  end

  defp start_and_populate_agent(fabricators) do
    FabricatorsRepo.start_link
    FabricatorsRepo.update(fabricators)
  end

  defp read_file!(file) do
    try do
      {fabricators, binding} = Code.eval_file(file)

      fabricators = case List.keyfind(binding, {:builder_agent, ExFabricators.Builder}, 0) do
        {_, agent} -> get_fabricators_and_stop_agent(agent)
        nil        -> fabricators
      end
      fabricators
    rescue
      e in [LoadError] -> reraise(e, System.stacktrace)
      e -> reraise(LoadError, [file: file, error: e], System.stacktrace)
    end 
  end

  defp get_fabricators_and_stop_agent(agent) do
    fabricators = ExFabricators.Builder.Agent.get(agent)
    ExFabricators.Builder.Agent.stop(agent)
    fabricators
  end

  defp instantiate_struct({struct, default_options_fn}, options) do
    struct
    |> Kernel.struct(default_options_fn.())
    |> Map.merge(options)
  end
end
