defmodule BeesWithScope.GHAuth do
  def fetch_pr(repo_owner, repo_name, number) do
    case Req.get("https://api.github.com/repos/#{repo_owner}/#{repo_name}/pulls/#{number}") do
      {:ok, %{status: 200, body: body}} -> {:ok, body}
      {:ok, %{status: status}} -> {:error, {:http_status, status}}
      {:error, reason} -> {:error, reason}
    end
  end
end
