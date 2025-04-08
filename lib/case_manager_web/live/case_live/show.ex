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
          <:subtitle>{@case.id}</:subtitle>
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
        {@case.description}
      </:left>
      <:right>
        <div class="flex flex-col h-full">
          <div class="overflow-y-auto flex-grow mb-4">
            <%= for {id, comment} <- @case.comments do %>
              <div>{comment.body}</div>
            <% end %>
          </div>
          <div class="mt-auto pt-2">
            <.form phx-submit="save_comment">
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
     |> assign(:case, Incidents.get_case!(id, load: :comments))}
  end
end
