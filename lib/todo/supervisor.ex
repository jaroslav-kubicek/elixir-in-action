defmodule Todo.Supervisor do
  @moduledoc false
  
  use Supervisor

  def start_link() do
    Supervisor.start_link(__MODULE__, [])
  end

  def init(_) do
    children = [
      worker(Todo.Database, []),
      worker(Todo.Cache, [])
    ]

    supervise(children, strategy: :one_for_one)
  end
end