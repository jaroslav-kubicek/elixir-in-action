defmodule Todo.Server do
  @moduledoc false

  use GenServer

  def start_link(name, init_items \\ []) do
    GenServer.start_link(__MODULE__, {name, init_items})
  end

  def add_todo(pid, todo) do
    GenServer.cast(pid, {:add, todo})
  end

  def get_todo(pid, id) do
    GenServer.call(pid, {:get, id})
  end

  # Behaviour implementation:

  def init({name, init_items}) do
    stored_list = Todo.Database.get(name)
    todo_list = case stored_list do
      %Todo.List{} -> merge_todo_items(stored_list, init_items)
      _ -> Todo.List.new(init_items)
    end
    {:ok, {name, todo_list}}
  end

  def handle_call({:get, id}, _from, {_name, %Todo.List{items: items} = todo_list}) do
    item = items[id]
    reply = case item do
         nil -> {:error, "Not Found"}
         _ -> {:ok, item}
      end
    {:reply, reply, todo_list}
  end

  def handle_cast(
    {:add, todo},
    {name, %Todo.List{} = todo_list}
  ) do
    new_todos = Todo.List.add_todo(todo_list, todo)
    Todo.Database.store(name, new_todos)
    {:noreply, {name, new_todos}}
  end

  defp merge_todo_items(stored_list, items) do
    Enum.reduce(
      items,
      stored_list,
      fn item, memo -> Todo.List.add_todo(memo, item) end
    )
  end
end