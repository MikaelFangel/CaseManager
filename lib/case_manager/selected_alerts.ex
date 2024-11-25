defmodule CaseManager.SelectedAlerts do
  @moduledoc """
  GenServer that holds the state of which alerts a user has selected. This is only meant
  to store data for the mssp users.
  """
  use GenServer

  @table_name :selected_alerts

  # Starts the GenServer and creates an ETS table
  def start_link(_args) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_args) do
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
  def toggle_alert_selection(user_id, alert_id, team_id) do
    GenServer.call(__MODULE__, {:toggle_alert_selection, user_id, alert_id, team_id})
  end

  @doc """
  Drops the selected alerts for a given user.
  """
  def drop_selected_alerts(user_id) do
    GenServer.call(__MODULE__, {:drop_selected_alerts, user_id})
  end

  @impl true
  def handle_call({:toggle_alert_selection, user_id, alert_id, team_id}, _from, state) do
    selected_alerts = get_selected_alerts(user_id)

    case Map.get(state, user_id) do
      nil ->
        updated_alerts = [alert_id | selected_alerts]
        :ets.insert(@table_name, {user_id, updated_alerts})
        new_state = Map.put(state, user_id, %{team_id: team_id})
        {:reply, :ok, new_state}

      %{team_id: ^team_id} ->
        updated_alerts = toggle_alert(selected_alerts, alert_id)
        :ets.insert(@table_name, {user_id, updated_alerts})

        if updated_alerts == [] do
          :ets.delete(@table_name, user_id)
          new_state = Map.delete(state, user_id)
          {:reply, :ok, new_state}
        else
          {:reply, :ok, state}
        end

      %{team_id: _existing_team_id} ->
        {:reply, {:error, :team_mismatch}, state}
    end
  end

  @impl true
  def handle_call({:drop_selected_alerts, user_id}, _from, state) do
    :ets.delete(@table_name, user_id)
    new_state = Map.delete(state, user_id)
    {:reply, :ok, new_state}
  end

  defp toggle_alert(selected_alerts, alert_id) do
    if Enum.member?(selected_alerts, alert_id) do
      List.delete(selected_alerts, alert_id)
    else
      [alert_id | selected_alerts]
    end
  end
end
