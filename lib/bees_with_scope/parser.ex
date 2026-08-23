defmodule BeesWithScope.Parser do
  @pr_ref ~r/([\w-]+)[:\/]([\w-]+)#(\d+)/
  @bare_ref ~r/#(\d+)/

  def parse(text) do
    case Regex.run(@pr_ref, text) do
      [_full, owner, repo, number] ->
        {:ok, %{owner: owner, repo: repo, number: number}}

      _ ->
        case Regex.run(@bare_ref, text) do
          [_text, number] ->
            {:ok, %{owner: "hackclub", repo: "site", number: number}}

          nil ->
            :error
        end
    end
  end
end
