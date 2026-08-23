defmodule Slack.SocketInteractiveTest do
  use ExUnit.Case, async: false

  defmodule FakeBot do
    use GenServer

    def start_link(_), do: GenServer.start_link(__MODULE__, [], name: __MODULE__)

    def init(state), do: {:ok, state}

    def handle_event(type, payload, _bot), do: GenServer.cast(__MODULE__, {type, payload})

    def events do
      GenServer.call(__MODULE__, :events)
    end

    def handle_call(:events, _from, events), do: {:reply, Enum.reverse(events), events}

    def handle_cast(event, events), do: {:noreply, [event | events]}
  end

  setup do
    start_supervised!(FakeBot)

    start_supervised!(
      {PartitionSupervisor, child_spec: Task.Supervisor, name: Slack.TaskSupervisors}
    )

    bot = %{module: FakeBot, user_id: "U_BOT", bot_id: "B_BOT", token: "xoxb-test"}
    %{bot: bot}
  end

  test "interactive block_actions envelope is acked and dispatched to the bot", %{bot: bot} do
    payload = %{
      "type" => "block_actions",
      "user" => %{"id" => "U_CLICKER"},
      "actions" => [%{"action_id" => "join_channel", "type" => "button"}]
    }

    envelope = %{"envelope_id" => "env-123", "type" => "interactive", "payload" => payload}

    assert {:reply, {:text, ack}, state} =
             Slack.Socket.handle_frame({:text, Jason.encode!(envelope)}, %{bot: bot})

    assert Jason.decode!(ack) == %{"envelope_id" => "env-123"}
    assert state.bot == bot

    wait_until(fn ->
      FakeBot.events() == [{"block_actions", payload}]
    end)
  end

  defp wait_until(fun, tries \\ 50)

  defp wait_until(fun, 0) do
    fun.()
  end

  defp wait_until(fun, tries) do
    if fun.() do
      true
    else
      Process.sleep(10)
      wait_until(fun, tries - 1)
    end
  end
end
