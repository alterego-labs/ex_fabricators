defmodule ExFabricators.Builder.Agent do
  @moduledoc false

  @typep fabricators :: Keyword.t

  @spec start_link() :: {:ok, pid}
  def start_link do
    Agent.start_link fn -> [] end
  end

  @spec stop(pid) :: :ok
  def stop(agent) do
    Agent.stop(agent)
  end

  @spec get(pid) :: fabricators
  def get(agent) do
    Agent.get(agent, &(&1))
  end

  @spec merge(pid, fabricators) :: fabricators
  def merge(agent, new_fabricators) do
    Agent.update(agent, &ExFabricators.Builder.merge(&1, new_fabricators))
  end
end
