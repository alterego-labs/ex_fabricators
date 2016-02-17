defmodule ExFabricators.FabricatorsRepo do
  @moduledoc false

  @typep fabricators :: Keyword.t

  @spec start_link() :: {:ok, pid}
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @spec get() :: fabricators
  def get do
    Agent.get(__MODULE__, &(&1))
  end

  @spec update(fabricators) :: :ok
  def update(fabricators) do
    Agent.update(__MODULE__, fn(_) -> fabricators end)
  end
end
