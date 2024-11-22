defmodule App.ThingWorker do
  use Oban.Worker

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    App.Repo.transaction(fn ->
      thing = App.Repo.get!(App.Thing, id)

      # Do something with the thing
      IO.inspect(thing)
    end)
  end
end
