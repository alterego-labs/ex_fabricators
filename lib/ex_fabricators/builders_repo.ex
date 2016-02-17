defmodule ExFabricators.BuildersRepo do
  @moduledoc false

  @typep config :: Keyword.t

  @spec start_link() :: {:ok, pid}
  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  @spec get() :: config
  def get do
    Agent.get(__MODULE__, &(&1))
  end

  @spec update(config) :: :ok
  def update(config) do
    Agent.update(__MODULE__, fn(_) -> config end)
  end
end
