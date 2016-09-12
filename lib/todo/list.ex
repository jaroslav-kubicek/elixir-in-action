defmodule Todo.List do
  @moduledoc false

  defstruct increment: 0, items: %{}

  def new(items \\ []) do
    Enum.reduce(
      items,
      %Todo.List{},
      &add_todo(&2, &1)
    )
  end

  def add_todo(
    %Todo.List{increment: increment, items: items} = todo_list,
    %{date: _} = todo
  ) do
    todo = Map.put(todo, :id, increment)
    items = Map.put(items, increment, todo)

    %Todo.List{todo_list | items: items, increment: increment + 1}
  end

  def add_todo(todo_list, todo) when is_bitstring(todo) do
    date = DateTime.to_date(DateTime.utc_now())
    todo_item = %{text: todo, date: date}
    add_todo(todo_list, todo_item)
  end

  def get_todo(%Todo.List{items: items}, id) do
    items[id]
  end

  def entries_by_date(%Todo.List{items: items}, date) do
    items
      |> Stream.filter(fn({_, todo}) -> todo.date == date end)
      |> Enum.map(fn({_, todo}) -> todo end)
  end
end