defmodule Todo.Cache do
  @moduledoc false
  
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, [name: :cache])
  end

  def get_todo_list(cache_pid, name) do
    GenServer.call(cache_pid, {:get_list, name})
  end

  def handle_call({:get_list, name}, _from, %{} = state) do
    case state[name] do
      nil ->
        {:ok, pid} = Todo.Server.start_link(name)
        {:reply, pid, Map.put(state, name, pid)}
      pid ->
        {:reply, pid, state}
    end
  end
end