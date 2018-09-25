defmodule Mix.Tasks.Poncho.Deps.Tree do
  use Mix.Task

  @shortdoc "Prints the dependency tree for the poncho project"

  @switches [base_dir: :string]
  @aliases [b: :base_dir]

  def run(args) do
    {opts, [project_name], _} = OptionParser.parse(args, aliases: @aliases, switches: @switches)

    opts = Keyword.merge([base_dir: "."], opts)
		project = String.to_atom(project_name)

    Mix.Project.in_project(project, "#{opts[:base_dir]}/#{project_name}", fn(module) ->
      deps = Mix.Dep.load_on_environment([])
      callback = callback(&format_tree/1, deps, [])
      Mix.Utils.print_tree([project], callback, [])
    end)
  end

  defp callback(formatter, deps, opts) do
    top_level = Enum.filter(deps, & &1.top_level)

    fn
      %Mix.Dep{app: app} = dep ->
        deps =
          if !poncho_dep?(dep) || (not dep.top_level && find_dep(top_level, app)) do
            []
          else
            find_dep(deps, app).deps
          end

        {{Atom.to_string(dep.app), nil}, filter_ponchos(deps)}

      app ->
        {{Atom.to_string(app), nil}, filter_ponchos(top_level)}
    end
  end

  defp find_dep(deps, app) do
    Enum.find(deps, &(&1.app == app))
  end

  defp filter_ponchos(deps) do
    Enum.filter(deps, &poncho_dep?/1)
  end

  defp poncho_dep?(%Mix.Dep{app: name, scm: Mix.SCM.Path, opts: opts}) do
    opts[:path] == "../#{name}"
  end

  defp poncho_dep?(%Mix.Dep{}), do: false
end

