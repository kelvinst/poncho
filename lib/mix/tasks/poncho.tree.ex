defmodule Mix.Tasks.Poncho.Tree do
  use Mix.Task

  @shortdoc "Prints the dependency tree for the poncho project"

  @switches [base_dir: :string, reverse: :boolean, master: :string]
  @aliases [b: :base_dir, r: :reverse, m: :master]

  @default_opts [base_dir: ".", reverse: false, master: "nil"]
  @indent 4

  def run(args) do
    {opts, args, _} = OptionParser.parse(args, aliases: @aliases, switches: @switches)
    opts = Keyword.merge(@default_opts, opts)

    project = case args do
      [] -> master(opts) || Poncho.config(opts[:base_dir]).master
      [project_name] -> String.to_atom(project_name)
    end

    formatted_deps =
      project
      |> dep_tree(opts)
      |> format_deps(@indent, [])

    [project | formatted_deps]
    |> Enum.join("\n")
    |> Mix.shell().info()
  end

  defp dep_tree(app, opts), do: dep_tree(app, opts[:reverse], opts[:base_dir], master(opts))

  defp dep_tree(app, true, base_dir, master), do: Poncho.reverse_dep_tree!(app, base_dir, master)
  defp dep_tree(app, false, base_dir, _), do: Poncho.dep_tree!(app, base_dir)

  defp master(opts), do: String.to_atom(opts[:master])

  defp format_deps([], _, acc), do: acc

  defp format_deps([{dep, deps} | tail], depth, acc) do
    dep_list = [
      "#{String.duplicate(" ", depth)}#{dep}" |
      format_deps(deps, depth + @indent, [])
    ]
    format_deps(tail, depth, dep_list ++ acc)
  end

  defp format_deps([dep | tail], depth, acc) do
    format_deps(tail, depth, ["#{String.duplicate(" ", depth)}#{dep}" | acc])
  end
end

