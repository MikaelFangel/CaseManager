defmodule CaseManager.SelectedAlerts do
  use GenServer

  @table_name :selected_alerts

  # Starts the GenServer and creates an ETS table
  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_) do
    :ets.new(@table_name, [
      :named_table,
      :public,
      :set,
      read_concurrency: true,
      write_concurrency: true
    ])

    {:ok, %{}}
  end

  @doc """
  Retrieves the selected alerts for a given user.
  """
  def get_selected_alerts(user_id) do
    case :ets.lookup(@table_name, user_id) do
      [{^user_id, selected_alerts}] -> selected_alerts
      [] -> []
    end
  end

  @doc """
  Toggles the selection state of an alert for a given user.
  """
  def toggle_alert_selection(user_id, alert_id) do
    GenServer.call(__MODULE__, {:toggle_alert_selection, user_id, alert_id})
  end

  @doc """
  Drops the selected alerts for a given user.
  """
  def drop_selected_alerts(user_id) do
    GenServer.call(__MODULE__, {:drop_selected_alerts, user_id})
  end

  @impl true
  def handle_call({:toggle_alert_selection, user_id, alert_id}, _from, state) do
    selected_alerts = get_selected_alerts(user_id)

    updated_alerts =
      if Enum.member?(selected_alerts, alert_id),
        do: List.delete(selected_alerts, alert_id),
        else: [alert_id | selected_alerts]

    :ets.insert(@table_name, {user_id, updated_alerts})
    {:reply, :ok, state}
  end

  @impl true
  def handle_call({:drop_selected_alerts, user_id}, _from, state) do
    :ets.delete(@table_name, user_id)
    {:reply, :ok, state}
  end
end
