defmodule CaseManagerWeb.CaseLive.Show do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.split flash={@flash} left_width="w-2/3" right_width="w-1/3" user_roles={@user_roles} show_mobile_panel={@show_mobile_panel}>
      <:top>
        <.header>
          {@case.title}
          <.badge type={status_to_badge_type(@case.status)} modifier={:outline}>
            {@case.status |> to_string() |> String.split("_") |> Enum.join(" ") |> String.capitalize()}
          </.badge>
          <:actions>
            <.button navigate={~p"/case"}>
              <.icon name="hero-arrow-left" />
            </.button>
            <.button :if={!@case.escalated} phx-click="escalate_case">
              Escalate case
            </.button>
            <.button variant="primary" navigate={~p"/case/#{@case}/edit?return_to=show"}>
              <.icon name="hero-pencil-square" /> Edit case
            </.button>
          </:actions>
        </.header>
      </:top>

      <:left>
        <div class="border border-base-300 rounded-lg shadow p-4 mb-4 text-sm">
          <div class="grid grid-cols-3 gap-4 items-center">
            <div class="text-left">
              {@case.company.name}
            </div>
            <div class="text-center">
              {@case.inserted_at}
            </div>
            <div class="text-right">
              {@case.soc.name}
            </div>
            <div>Reported by: <span class="font-semibold">{@case.reporter.full_name}</span></div>
            <div class="text-center">{@case.resolution_type}</div>
            <div :if={@case.assignee} class="text-right">Assignee: <span class="font-semibold">{@case.assignee.full_name}</span></div>
          </div>
          <Layouts.divider />
          <p>{@case.description}</p>
        </div>

        <%= for {alert, index} <- Enum.with_index(@case.alerts || []) do %>
          <div class="collapse border border-base-300 bg-base-100">
            <input type="radio" name="alert-accordion" id={"alert-#{index}"} />
            <div class="collapse-title text-sm">
              {alert.title} - <span class="text-xs text-base-content/50">{alert.severity |> to_string() |> String.capitalize()}</span>
            </div>
            <div class="collapse-content flex flex-col text-xs">
              <p class="mb-4">{alert.description}</p>
              <%!-- <.button navigate={~p"/alert/#{case.id}"}>Open</.button> --%>
            </div>
          </div>
        <% end %>
      </:left>
      <:right>
        <div class="flex flex-col h-full sticky top-0">
          <div class="flex flex-col items-center">
            <div class="tabs tabs-boxed sticky top-0 z-10 bg-base-100">
              <a class={"tab #{if @active_visibility == :public, do: "tab-active"}"} phx-click="switch_visibility" phx-value-visibility="public">
                <.icon name="hero-globe-alt" class="mr-1 h-4 w-4" /> Public
              </a>
              <a class={"tab #{if @active_visibility == :internal, do: "tab-active"}"} phx-click="switch_visibility" phx-value-visibility="internal">
                <.icon name="hero-building-office" class="mr-1 h-4 w-4" /> Internal
              </a>
              <a class={"tab #{if @active_visibility == :personal, do: "tab-active"}"} phx-click="switch_visibility" phx-value-visibility="personal">
                <.icon name="hero-lock-closed" class="mr-1 h-4 w-4" /> Personal
              </a>
            </div>
          </div>

          <div class="overflow-y-auto flex-1 my-4 flex flex-col-reverse" id="comments" phx-update="stream">
            <%= if @streams.comments == [] do %>
              <div class="flex-1 h-full flex flex-col justify-center items-center text-base-content/70">
                <.icon name="hero-chat-bubble-left-ellipsis" class="h-12 w-12 mb-2 opacity-50" />
                <p>No comments with {@active_visibility} visibility</p>
              </div>
            <% else %>
              <%= for {id, comment} <- @streams.comments do %>
                <.chat_bubble id={id} comment={comment} user_id={@user_id} />
              <% end %>
            <% end %>
          </div>

          <div class="sticky bottom-0 bg-base-100">
            <div class={"order-base-300 rounded-lg #{visibility_theme_class(@active_visibility)}"}>
              <.form for={@comment_form} id="comment-form" phx-validate="validate_comment" phx-submit="add_comment" class="w-full mt-2 px-3 pb-3">
                <.input field={@comment_form[:visibility]} type="hidden" value={@active_visibility} />

                <div class="flex items-center">
                  <span class={"inline-flex items-center gap-1 text-sm font-medium #{visibility_text_color(@active_visibility)}"}>
                    Posting to {@active_visibility}
                  </span>
                </div>
                <p class="mb-2 text-xs text-base-content/50">This comment will only be visible to {visibility_audience(@active_visibility)}.</p>

                <.input field={@comment_form[:body]} type="textarea" placeholder="Write a comment..." class="w-full" />

                <button class={"btn w-full #{visibility_button_class(@active_visibility)}"}>
                  <.icon name="hero-paper-airplane" /> Send
                </button>
              </.form>
            </div>
          </div>
        </div>
      </:right>
    </Layouts.split>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    user = Ash.load!(socket.assigns.current_user, [:soc_roles, :company_roles, :super_admin?])

    if connected?(socket) do
      CaseManagerWeb.Endpoint.subscribe("comment:" <> id)
    end

    case =
      Incidents.get_case!(id,
        load: [:soc, :company, :alerts, reporter: [:full_name], assignee: [:full_name]],
        actor: user
      )

    initial_visibility = :public

    comments = Incidents.get_comments_for_case!(id, initial_visibility, actor: user)

    {:ok,
     socket
     |> assign(:page_title, "Show Case")
     |> assign(:user_roles, user.soc_roles ++ user.company_roles)
     |> assign(:active_visibility, initial_visibility)
     |> assign(:case, case)
     |> assign(:show_mobile_panel, false)
     |> stream(:comments, comments)
     |> assign(:user_id, socket.assigns.current_user.id)}
  end

  @impl true
  def handle_params(_unsigned_params, _uri, socket) do
    socket =
      assign(
        socket,
        :comment_form,
        to_form(
          CaseManager.Incidents.form_to_add_comment_to_case(socket.assigns.case, actor: socket.assigns.current_user)
        )
      )

    {:noreply, socket}
  end

  @impl true
  def handle_event("switch_visibility", %{"visibility" => visibility}, socket) do
    visibility_atom = String.to_existing_atom(visibility)
    user = Ash.load!(socket.assigns.current_user, :super_admin?)

    comments =
      Incidents.get_comments_for_case!(socket.assigns.case.id, visibility_atom, actor: user)

    {:noreply,
     socket
     |> assign(:active_visibility, visibility_atom)
     |> stream(:comments, comments, reset: true)}
  end

  @impl true
  def handle_event("validate_comment", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.comment_form, params)
    {:noreply, assign(socket, comment_form: form)}
  end

  @impl true
  def handle_event("add_comment", %{"form" => form}, socket) do
    form = %{comment: form}

    case AshPhoenix.Form.submit(socket.assigns.comment_form, params: form) do
      {:ok, _comment} ->
        socket = push_navigate(socket, to: ~p"/case/" <> socket.assigns.case.id)
        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, :comment_form, form)}
    end
  end

  @impl true
  def handle_event("escalate_case", _params, socket) do
    user = Ash.load!(socket.assigns.current_user, :super_admin?)
    updated_case = Incidents.update_case!(socket.assigns.case, %{escalated: true}, actor: user)
    {:noreply, assign(socket, :case, updated_case)}
  end

  @impl true
  def handle_event("toggle_mobile_panel", _params, socket) do
    {:noreply, assign(socket, :show_mobile_panel, !socket.assigns.show_mobile_panel)}
  end

  @impl true
  def handle_info(%{topic: "comment" <> _, event: "create", payload: notification}, socket) do
    if notification.data.visibility == socket.assigns.active_visibility do
      comment = Ash.load!(notification.data, user: [:full_name])
      {:noreply, stream_insert(socket, :comments, comment, at: 0)}
    else
      {:noreply, socket}
    end
  end

  defp status_to_badge_type(status) do
    case status do
      :new -> :info
      :open -> :info
      :in_progress -> :warning
      :pending -> :warning
      :resolved -> :success
      :closed -> :neutral
      :reopened -> :error
      _ -> :neutral
    end
  end

  defp visibility_theme_class(visibility) do
    case visibility do
      :public -> "bg-success/10"
      :internal -> "bg-warning/10"
      :personal -> "bg-error/10"
      _ -> ""
    end
  end

  defp visibility_button_class(visibility) do
    case visibility do
      :public -> "btn-success"
      :internal -> "btn-warning"
      :personal -> "btn-error"
      _ -> "btn-primary"
    end
  end

  defp visibility_text_color(visibility) do
    case visibility do
      :public -> "text-success"
      :internal -> "text-warning"
      :personal -> "text-error"
      _ -> ""
    end
  end

  defp visibility_audience(visibility) do
    case visibility do
      :public -> "everyone"
      :internal -> "MSSP team members"
      :personal -> "administrators and yourself"
      _ -> "unknown audience"
    end
  end
end
