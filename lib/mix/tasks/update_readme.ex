defmodule Mix.Tasks.UpdateReadme do
  use Mix.Task

  @shortdoc "update README.md with the documentation from Pollution.VG"
  def run(_) do
    opts = %{
      source_url_pattern: "",
      source_root: "",
    }

    [mod] = ExDoc.Retriever.docs_from_modules([Pollution.VG], opts)

    result =
      Enum.reduce(mod.docs, ["<!-- pollution -->"], &fn_docs/2)
      |> (&[ &2 | &1 ]).("<!-- cleanup -->")
      |> Enum.reverse
      |> Enum.join("\n")

    readme =
        File.read!("README.md")
        |> String.replace(~r{<!-- pollution -->[.\n]*<!-- cleanup -->\n}, result)


    File.write!("README.md", readme)
  end

  def fn_docs(f = %ExDoc.FunctionNode{doc: nil}, result) do
    [ signature(f.signature) | result ]
  end

  def fn_docs(f = %ExDoc.FunctionNode{}, result) do
    indented_doc =
      String.split(f.doc, "\n")
      |> Enum.map(&"  #{&1}")
      |> Enum.join("\n")
      |> String.replace("## ", "### ")
    [ indented_doc, signature(f.signature) | result ]
  end

  def signature(sig) do
    "\n* \#\# #{String.replace(sig, "\\\\", "\\\\\\\\")}\n"
  end
end
