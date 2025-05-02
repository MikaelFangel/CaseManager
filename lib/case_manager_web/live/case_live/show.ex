defmodule CaseManagerWeb.CaseLive.Show do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents
  alias CaseManagerWeb.DataDisplay

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.split flash={@flash} left_width="w-2/3" right_width="w-1/3">
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
            <.button :if={!@case.escalated}>
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
              {alert.title} - <span class="text-xs text-base-content/50">{alert.risk_level |> to_string() |> String.capitalize()}</span>
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

          <div class="overflow-y-auto flex-1 my-4 flex flex-col-reverse">
            <%= if Enum.empty?(@filtered_comments) do %>
              <div class="flex-1 h-full flex flex-col justify-center items-center text-base-content/70">
                <.icon name="hero-chat-bubble-left-ellipsis" class="h-12 w-12 mb-2 opacity-50" />
                <p>No comments with {@active_visibility} visibility</p>
              </div>
            <% else %>
              <%= for comment <- @filtered_comments do %>
                <DataDisplay.chat_bubble comment={comment} user_id={@user_id} />
              <% end %>
            <% end %>
          </div>

          <div class="sticky bottom-0 bg-base-100">
            <div class={"order-base-300 rounded-lg #{visibility_theme_class(@active_visibility)}"}>
              <.form for={@comment_form} id="comment-form" phx-validate="validate_comment" phx-submit="add_comment" class="mt-2 px-3 pb-3">
                <.input field={@comment_form[:visibility]} type="hidden" value={@active_visibility} />

                <div class="flex items-center">
                  <span class={"inline-flex items-center gap-1 text-sm font-medium #{visibility_text_color(@active_visibility)}"}>
                    Posting to {@active_visibility}
                  </span>
                </div>
                <p class="mb-2 text-xs text-base-content/50">This comment will only be visible to {visibility_audience(@active_visibility)}.</p>

                <.input field={@comment_form[:body]} type="textarea" placeholder="Write a comment..." />

                <button type="submit" class={"btn #{visibility_button_class(@active_visibility)}"}>
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
    case =
      Incidents.get_case!(id,
        load: [:soc, :company, :alerts, reporter: [:full_name], assignee: [:full_name]]
      )

    initial_visibility = :public

    comments = Incidents.get_comments_for_case!(id, initial_visibility)

    {:ok,
     socket
     |> assign(:page_title, "Show Case")
     |> assign(:active_visibility, initial_visibility)
     |> assign(:case, case)
     # Store filtered comments separately
     |> assign(:filtered_comments, comments)
     |> assign(:user_id, socket.assigns.current_user.id)
     |> assign(
       :comment_form,
       to_form(CaseManager.Incidents.form_to_add_comment_to_case(case, actor: socket.assigns.current_user))
     )}
  end

  @impl true
  def handle_event("switch_visibility", %{"visibility" => visibility}, socket) do
    visibility_atom = String.to_existing_atom(visibility)
    comments = Incidents.get_comments_for_case!(socket.assigns.case.id, visibility_atom)

    {:noreply,
     socket
     |> assign(:active_visibility, visibility_atom)
     |> assign(:filtered_comments, comments)}
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
        {:noreply, put_flash(socket, :info, gettext("Comment added successfully."))}

      {:error, form} ->
        {:noreply, assign(socket, :comment_form, form)}
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
