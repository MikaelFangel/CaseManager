defmodule CaseManagerWeb.CaseLive.Show do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

  @impl true
  def render(assigns) do
    ~H"""
    <div id="platform-detector-case" phx-hook="PlatformDetector" style="display: none;"></div>
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
            <.button :if={@soc_user} variant="primary" navigate={~p"/case/#{@case}/edit?return_to=show"}>
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
            <div class="text-right">
              <%= if @case.assignee do %>
                <div class="flex items-center justify-end gap-2">
                  <span>Assignee: <span class="font-semibold">{@case.assignee.full_name}</span></span>
                  <button :if={@soc_user} phx-click="toggle_assign_form" class="btn btn-xs btn-ghost">
                    <.icon name="hero-pencil" class="w-3 h-3" />
                  </button>
                </div>
              <% else %>
                <div class="flex items-center justify-end gap-2">
                  <span class="text-base-content/50">No assignee</span>
                  <button :if={@soc_user} phx-click="toggle_assign_form" class="btn btn-xs btn-primary">
                    <.icon name="hero-plus" class="w-3 h-3" /> Assign
                  </button>
                </div>
              <% end %>
              <%= if @show_assign_form do %>
                <.form for={@assign_form} id="assign-form" phx-change="validate_assign" phx-submit="assign_user" class="mt-2">
                  <div class="flex items-center gap-2">
                    <.input field={@assign_form[:user_id]} type="select" options={assignee_options(@company_users)} value={@case.assignee && @case.assignee.id} class="select select-sm" />
                    <.button variant="primary" phx-disable-with="Assigning...">Assign</.button>
                    <.button type="button" phx-click="toggle_assign_form">Cancel</.button>
                  </div>
                </.form>
              <% end %>
            </div>
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
              <.form for={@comment_form} id="comment-form" phx-validate="validate_comment" phx-submit="add_comment" class="w-full mt-2 px-3 pb-3" phx-hook="ClearTextarea">
                <.input field={@comment_form[:visibility]} type="hidden" value={@active_visibility} />

                <div class="flex items-center">
                  <span class={"inline-flex items-center gap-1 text-sm font-medium #{visibility_text_color(@active_visibility)}"}>
                    Posting to {@active_visibility}
                  </span>
                </div>
                <p class="mb-2 text-xs text-base-content/50">This comment will only be visible to {visibility_audience(@active_visibility)}.</p>

                <.input field={@comment_form[:body]} type="textarea" placeholder="Write a comment..." class="w-full" phx-hook="CtrlEnterSubmit" />

                <div class="flex items-center justify-between mt-2">
                  <div class="text-xs text-base-content/50 flex items-center gap-1">
                    <kbd class="kbd kbd-sm">{if @is_mac, do: "⌘", else: "ctrl"}</kbd> + <kbd class="kbd kbd-sm">↵</kbd> to send
                  </div>
                  <button class={"btn #{visibility_button_class(@active_visibility)}"}>
                    <.icon name="hero-paper-airplane" /> Send
                  </button>
                </div>
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
    user =
      Ash.load!(socket.assigns.current_user, [:soc_roles, :company_roles, :super_admin?, :socs])

    if connected?(socket) do
      CaseManagerWeb.Endpoint.subscribe("comment:" <> id <> ":comments")
    end

    case =
      Incidents.get_case!(id,
        load: [:soc, :company, :alerts, reporter: [:full_name], assignee: [:full_name]],
        actor: user
      )

    initial_visibility = :public

    comments = Incidents.get_comments_for_case!(id, initial_visibility, actor: user)

    company_users = CaseManager.Accounts.get_users_by_company!(case.company.id, actor: user)

    socket =
      socket
      |> assign(:page_title, "Show Case")
      |> assign(:user_roles, user.soc_roles ++ user.company_roles)
      |> assign(:active_visibility, initial_visibility)
      |> assign(:case, case)
      |> assign(:soc_user, Enum.any?(user.socs, fn soc -> soc.id == case.soc.id end) or user.super_admin?)
      |> assign(:show_mobile_panel, false)
      |> assign(:company_users, company_users)
      |> assign(:show_assign_form, false)
      |> stream(:comments, comments)
      |> assign(:user_id, socket.assigns.current_user.id)
      |> assign(:is_mac, false)

    {:ok, socket}
  end

  @impl true
  def handle_params(_unsigned_params, _uri, socket) do
    user = Ash.load!(socket.assigns.current_user, :super_admin?)

    socket =
      socket
      |> assign(
        :comment_form,
        to_form(Incidents.form_to_add_comment_to_case(socket.assigns.case, actor: user))
      )
      |> assign(
        :assign_form,
        to_form(Incidents.form_to_assign_user_to_case(socket.assigns.case, actor: user))
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
        socket = push_event(socket, "clear-textarea", %{})
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

  def handle_event("platform_detected", %{"is_mac" => is_mac}, socket) do
    {:noreply, assign(socket, :is_mac, is_mac)}
  end

  @impl true
  def handle_event("toggle_assign_form", _params, socket) do
    {:noreply, assign(socket, :show_assign_form, !socket.assigns.show_assign_form)}
  end

  @impl true
  def handle_event("validate_assign", %{"form" => params}, socket) do
    form = AshPhoenix.Form.validate(socket.assigns.assign_form, params)
    {:noreply, assign(socket, assign_form: form)}
  end

  @impl true
  def handle_event("assign_user", %{"form" => form}, socket) do
    user = Ash.load!(socket.assigns.current_user, :super_admin?)

    case AshPhoenix.Form.submit(socket.assigns.assign_form, params: form) do
      {:ok, _assignment} ->
        updated_case =
          CaseManager.Incidents.get_case!(socket.assigns.case.id,
            load: [:soc, :company, :alerts, reporter: [:full_name], assignee: [:full_name]],
            actor: user
          )

        socket =
          socket
          |> assign(:case, updated_case)
          |> assign(:show_assign_form, false)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, :assign_form, form)}
    end
  end

  @impl true
  def handle_info(%{topic: "comment" <> _rest, event: "create", payload: notification}, socket) do
    comment_data = notification.data
    current_user = socket.assigns.current_user

    authorized =
      case comment_data.visibility do
        :public ->
          true

        :personal ->
          comment_data.user_id == current_user.id

        :internal ->
          user_with_socs = Ash.load!(current_user, [:socs, :super_admin?])
          case_soc_id = socket.assigns.case.soc.id
          Enum.any?(user_with_socs.socs, fn soc -> soc.id == case_soc_id end) or user_with_socs.super_admin?
      end

    if authorized and comment_data.visibility == socket.assigns.active_visibility do
      comment = Ash.load!(comment_data, user: [:full_name])
      {:noreply, stream_insert(socket, :comments, comment, at: 0)}
    else
      {:noreply, socket}
    end
  end

  defp assignee_options(users) do
    [{"No assignee", nil}] ++ Enum.map(users, fn user -> {user.full_name, user.id} end)
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
      _other -> :neutral
    end
  end

  defp visibility_theme_class(visibility) do
    case visibility do
      :public -> "bg-success/10"
      :internal -> "bg-warning/10"
      :personal -> "bg-error/10"
      _other -> ""
    end
  end

  defp visibility_button_class(visibility) do
    case visibility do
      :public -> "btn-success"
      :internal -> "btn-warning"
      :personal -> "btn-error"
      _other -> "btn-primary"
    end
  end

  defp visibility_text_color(visibility) do
    case visibility do
      :public -> "text-success"
      :internal -> "text-warning"
      :personal -> "text-error"
      _other -> ""
    end
  end

  defp visibility_audience(visibility) do
    case visibility do
      :public -> "everyone"
      :internal -> "MSSP team members"
      :personal -> "administrators and yourself"
      _other -> "unknown audience"
    end
  end
end
