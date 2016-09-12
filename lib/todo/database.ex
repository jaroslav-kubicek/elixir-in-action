defmodule Todo.Database do
  @moduledoc false
  
  use GenServer

  def start_link(folder \\ "./data") do
    GenServer.start_link(__MODULE__, %{folder: folder}, [name: :database_server])
  end

  def get(key) do
    GenServer.call(:database_server, {:get, key})
  end

  def store(key, data) do
    GenServer.cast(:database_server, {:store, key, data})
  end

  # behaviours:

  def init(%{folder: folder}) do
    File.mkdir_p!(folder)
    workers = 0..2 |>
        Enum.reduce(%{}, fn (i, memo) -> Map.put(memo, i, start_worker(folder)) end)
    {:ok, {folder, workers}}
  end

  def handle_call({:get, key}, _from, {_folder, workers} = state) do
    worker = get_worker(workers, key)
    stored_data = Todo.DatabaseWorker.get(worker, key)
    {:reply, stored_data, state}
  end

  def handle_cast({:store, key, data}, {_folder, workers} = state) do
    worker = get_worker(workers, key)
    Todo.DatabaseWorker.store(worker, key, data)
    {:noreply, state}
  end

  defp get_worker(%{} = workers, key) do
    worker_number = :erlang.phash2(key, 3)
    workers[worker_number]
  end

  defp start_worker(folder) do
     {:ok, pid} = Todo.DatabaseWorker.start_link(folder)
     pid
  end
end