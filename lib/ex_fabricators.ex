defmodule ExFabricators do
  @moduledoc false

  @spec take_all!(String.t) :: any()
  def take_all!(fabricators_path) do
    fabricators_path
    |> fetch_and_merge_all_builders
    |> start_and_populate_agent
  end

  @spec build(:atom, map()) :: struct()
  def build(name, options \\ %{}) do
    ExFabricators.BuildersRepo.get
    |> Keyword.get(name)
    |> instantiate_struct(options)
  end

  defp fetch_and_merge_all_builders(fabriactors_path) do
    fabricators_path
    |> Path.join("*_fabricator.exs")
    |> Path.wildcard
    |> Enum.map(&read_file!(&1))
    |> Enum.reduce([], fn(config, acc) ->
      validate!(acc, config)
      Keyword.merge(acc, config)
    end)
  end

  defp start_and_populate_agent(config) do
    ExFabricators.BuildersRepo.start_link
    ExFabricators.BuildersRepo.put(config)
  end

  defp read_file!(file) do
   try do
      {config, binding} = Code.eval_file(file)

      config = case List.keyfind(binding, {:builder_agent, ExFabricators.Builder}, 0) do
        {_, agent} -> get_config_and_stop_agent(agent)
        nil        -> config
      end
      config
    rescue
      e in [LoadError] -> reraise(e, System.stacktrace)
      e -> reraise(LoadError, [file: file, error: e], System.stacktrace)
    end 
  end

  defp get_config_and_stop_agent(agent) do
    config = ExFabricators.Builder.Agent.get(agent)
    ExFabricators.Builder.Agent.stop(agent)
    config
  end

  defp validate!(config, new_config) do
    new_config
    |> Keyword.keys
    |> Enum.each(fn(key) ->
      if Keyword.has_key?(config, key) do
        raise RuntimeError,
          "Fabricator for `#{Atom.to_string(key)}` already defined!"
      end
    end)
  end

  defp instantiate_struct({struct, default_options}, options) do
    struct
    |> Kernel.struct(default_options)
    |> Map.merge(options)
  end
end
