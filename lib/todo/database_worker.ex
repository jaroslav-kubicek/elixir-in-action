defmodule Todo.DatabaseWorker do
  @moduledoc false
  
  use GenServer

  def start_link(folder) do
    GenServer.start_link(__MODULE__, folder)
  end

  def store(pid, key, data) do
    GenServer.cast(pid, {:store, key, data})
  end

  def get(pid, key) do
    GenServer.call(pid, {:get, key})
  end

  # behaviours:

  def handle_call({:get, key}, _from, folder) do
    filename = get_filename(folder, key)
    reply = case File.read(filename) do
      {:ok, content} -> :erlang.binary_to_term(content)
      _ -> nil
    end

    {:reply, reply, folder}
  end

  def handle_cast({:store, key, data}, folder) do
    get_filename(folder, key)
      |> File.write!(:erlang.term_to_binary(data))

    {:noreply, folder}
  end

  defp get_filename(folder, key) do
    "#{folder}/#{key}.bin"
  end
end