defmodule CaseManagerWeb.AlertModal do
  @moduledoc """
  Provides a modal displaying an alert.
  """

  use Phoenix.Component
  use Gettext, backend: CaseManagerWeb.Gettext

  import CaseManagerWeb.BadgeTemplate
  import CaseManagerWeb.Button
  import CaseManagerWeb.Header
  import CaseManagerWeb.ModalTemplate
  import CaseManagerWeb.RiskBadge
  import CaseManagerWeb.Tooltip

  alias Phoenix.LiveView.JS

  attr :id, :string, default: "alert_modal"
  attr :show, :boolean, default: false
  attr :on_cancel, JS, default: %JS{}
  attr :alert, :map, required: true, doc: "alert to be displayed"

  def alert_modal(assigns) do
    ~H"""
    <.modal_template id={@id} show={@show} on_cancel={@on_cancel}>
      <div class="flex flex-row place-items-baseline gap-x-2.5 w-full">
        <.header class="flex-none font-bold">{@alert.title}</.header>
        <label class="flex-none text-gray-400 text-xs font-semibold">
          {@alert.creation_time}
        </label>

        <div class="flex place-items-baseline basis-full justify-end">
          <.risk_badge colour={@alert.risk_level} />
        </div>
      </div>

      <hr class="border-t border-gray-300 mt-1 mb-2.5" />

      <div class="flex flex-row justify-between">
        <div class="flex flex-wrap gap-x-2.5">
          <%= for case <- Ash.load!(@alert, :case).case do %>
            <.tooltip
              pos={:bottom}
              tooltip_label={case.status |> to_string() |> String.replace("_", " ") |> String.capitalize()}
            >
              <.badge_template
                class={"text-xs font-semibold font-mono " <>
                  case case.status do
                    :t_positive -> "bg-red-300"
                    :benign -> "bg-green-200"
                    :pending -> "bg-amber-100"
                    :f_positive -> "bg-gray-300"
                    :in_progress ->  "bg-sky-300"
                  end}
                label={case.id |> String.slice(0..7)}
              />
            </.tooltip>
          <% end %>
        </div>

        <label class="text-black text-sm font-bold">{@alert.team.name}</label>
      </div>

      <div class="pt-9 w-full">
        <span>
          {@alert.description}
        </span>
      </div>

      <%= if @alert.additional_data != %{} do %>
        <div class="mt-20 p-4 bg-slate-50 rounded-md shadow overflow-x-auto">
          <pre class="inline"><%= @alert.additional_data |> Jason.encode!(pretty: true) %></pre>
        </div>
      <% end %>

      <br />
      <div class="flex justify-end space-x-2">
        <.button colour={:secondary} phx-click={@on_cancel}>
          {gettext("Close")}
        </.button>
        <.link href={@alert.link} target="_blank">
          <.button>
            {gettext("Search Link")}
          </.button>
        </.link>
      </div>
    </.modal_template>
    """
  end
end
