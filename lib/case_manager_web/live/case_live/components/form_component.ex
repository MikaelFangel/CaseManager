defmodule CaseManagerWeb.CaseLive.FormComponent do
  use CaseManagerWeb, :live_component
  alias AshPhoenix.Form

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(:current_user, assigns[:current_user])
      |> assign(:team_name, assigns[:team_name])
      |> assign(:related_alerts, assigns[:related_alerts])
      |> assign(:files, assigns[:files] || [])
      |> assign(:form, assigns[:form])
      |> assign(:on_cancel, assigns[:on_cancel])
      |> assign(:uploaded_files, [])
      |> allow_upload(:attachments, accept: :any, max_entries: 10)
      |> assign(:alert, nil)

    {:ok, socket}
  end

  def handle_event("validate", params, socket) do
    form = Form.validate(socket.assigns.form, params)
    {:noreply, assign(socket, form: form)}
  end

  def handle_event(
        "save",
        %{"description" => description, "internal_note" => internal_note} = params,
        socket
      ) do
    team_id =
      socket.assigns.related_alerts
      |> Enum.at(0)
      |> elem(1)
      |> Map.get(:team)
      |> Map.get(:id)

    related_alert_ids =
      socket.assigns.related_alerts
      |> Enum.map(fn {_id, alert} -> alert.id end)

    sanitize = &(&1 |> HtmlSanitizeEx.strip_tags())

    params =
      params
      |> Map.put("description", sanitize.(description))
      |> Map.put("internal_note", sanitize.(internal_note))
      |> Map.put(:team_id, team_id)
      |> Map.put(:escalated, false)
      |> Map.put(:alert, related_alert_ids)
      |> Map.delete(:uploaded_files)

    action_opts = [actor: socket.assigns.current_user]

    case AshPhoenix.Form.submit(socket.assigns.form, params: params, action_opts: action_opts) do
      {:ok, case} ->
        consume_uploaded_entries(socket, :attachments, fn %{path: path}, entry ->
          file = File.read!(path)

          CaseManager.Cases.File
          |> Ash.Changeset.for_create(:create, %{
            case_id: case.id,
            filename: entry.client_name,
            content_type: entry.client_type,
            binary_data: file
          })
          |> Ash.create!()

          {:ok, "success"}
        end)

        socket =
          socket
          |> put_flash(:info, gettext("Case created successfully."))
          |> push_navigate(to: ~p"/case/#{case.id}")

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, :form, form)}
    end
  end

  @impl true
  def handle_event("show_modal", %{"alert_id" => alert_id}, socket) do
    alert = Ash.get!(CaseManager.Alerts.Alert, alert_id)

    socket =
      socket
      |> assign(:alert, alert)

    {:noreply, socket}
  end

  @impl true
  def handle_event("hide_modal", _params, socket) do
    socket =
      socket
      |> assign(:alert, nil)

    {:noreply, socket}
  end
end
