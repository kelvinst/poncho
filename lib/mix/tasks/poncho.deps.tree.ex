defmodule Mix.Tasks.Poncho.Deps.Tree do
  use Mix.Task

  @shortdoc "Prints the dependency tree for the poncho project"

  def run([project_name]) do
    project_name
    |> String.to_atom()
    |> Mix.Project.in_project("./#{project_name}", fn(module) ->
      Mix.shell().info("Here is the poncho dependency tree for: #{module}")
    end)
  end
end

