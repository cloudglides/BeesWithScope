defmodule BeesWithScope.Poster do
  def build(repo_owner, repo_name, number, pr) do
    [
      section_block(number, pr["title"]),
      context_block(repo_owner, repo_name, pr)
    ]
  end

  defp section_block(number, title) do
    %{
      type: "section",
      text: %{type: "mrkdwn", text: "*PR ##{number}:* #{title}"}
    }
  end

  defp context_block(repo_owner, repo_name, pr) do
    merged_by = get_in(pr, ["user", "login"]) || "unknown"
    date = pr["merged_at"] || pr["created_at"]

    %{
      type: "context",
      elements: [
        %{type: "mrkdwn", text: "by *#{merged_by}* in *#{repo_owner}/#{repo_name}* on #{date}"}
      ]
    }
  end
end
