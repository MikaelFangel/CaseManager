defmodule CaseManagerWeb.CaseLive.Show do
  @moduledoc false
  use CaseManagerWeb, :live_view

  alias CaseManager.Incidents

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
          <div class="divider"></div>
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
        <div class="flex flex-col h-full">
          <div class="overflow-y-auto flex-grow mb-4">
            <%= for {id, comment} <- @case.comments do %>
              <div id={id}>{comment.body}</div>
            <% end %>
          </div>
          <div class="mt-auto pt-2">
            <.form for={%{}} phx-submit="save_comment">
              <.input type="textarea" name="comment" value="" class="mb-2" />
              <.button>Send</.button>
            </.form>
          </div>
        </div>
      </:right>
    </Layouts.split>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    {:ok,
     socket
     |> assign(:page_title, "Show Case")
     |> assign(
       :case,
       Incidents.get_case!(id,
         load: [:comments, :soc, :company, :alerts, reporter: [:full_name], assignee: [:full_name]]
       )
     )}
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
end
