defmodule Xlack.Web do
  @moduledoc false

  @slack_docs_path :code.priv_dir(:xlack)
                   |> Path.join("slack")
                   |> Path.join("docs")

  def get_documentation do
    File.ls!(@slack_docs_path)
    |> format_documentation
  end

  defp format_documentation(files) do
    Enum.reduce(files, %{}, fn file, module_names ->
      json =
        @slack_docs_path
        |> Path.join(file)
        |> File.read!()
        |> Jason.decode!(%{})

      doc = Xlack.Web.Documentation.new(json, file)

      module_names
      |> Map.put_new(doc.module, [])
      |> update_in([doc.module], &(&1 ++ [doc]))
    end)
  end
end
