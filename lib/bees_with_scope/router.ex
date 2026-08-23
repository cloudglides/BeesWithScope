defmodule BeesWithScope.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/workflow/:name" do
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, landing_page(name))
  end

  post "/workflow/:name" do
    workflow = Application.get_env(:bees_with_scope, :workflow_mod, BeesWithScope.Workflow)

    case workflow.post(name) do
      {:ok, _} ->
        send_resp(conn, 200, "ok")

      {:error, reason} ->
        send_resp(conn, 502, inspect(reason))
    end
  end

  match _ do
    send_resp(conn, 404, "not found")
  end

  defp landing_page(name) do
    """
    <!doctype html>
    <html>
      <head><meta charset="utf-8"><title>#{name}</title></head>
      <body style="font-family: sans-serif; text-align: center; padding-top: 4rem;">
        <h1>#{name}</h1>
        <p>Open this link in Slack and hit the Join button.</p>
      </body>
    </html>
    """
  end
end
