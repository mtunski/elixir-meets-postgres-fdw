defmodule App do
  def insert_thing_and_work do
    App.Repo.transaction(fn ->
      thing = App.Repo.insert!(%App.Thing{})
      App.ThingWorker.new(%{id: thing.id}) |> Oban.insert!()

      # Simulate some more work
      Process.sleep(5000)
    end)
  end
end
