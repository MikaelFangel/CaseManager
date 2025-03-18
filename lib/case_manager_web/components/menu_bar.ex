defmodule CaseManagerWeb.MenuBar do
  @moduledoc """
  Renders a menubar.
  """

  use Phoenix.Component
  use Gettext, backend: CaseManagerWeb.Gettext

  import CaseManagerWeb.Icon
  import CaseManagerWeb.Tooltip

  @selection_circle "w-11 h-11 bg-gray-300/30 rounded-full z-0 absolute left-1/2 -translate-x-1/2 top-1/2 -translate-y-1/2"

  attr :current_page, :atom, required: true, doc: "the page the user is at"
  attr :current_user, :map, required: true, doc: "the user to check if customer or mssp"
  attr :type, :string, default: nil
  attr :class, :string, default: nil
  attr :rest, :global

  slot :inner_block, required: true

  def menu_bar(assigns) do
    ~H"""
    <div class="h-screen flex flex-row">
      <!-- The menu bar -->
      <div class="flex-col w-14 px-3 py-5 gap-24 bg-slate-950 justify-center items-start inline-flex">
        <!-- Top content -->
        <div class="flex-col w-full justify-start items-center gap-4 inline-flex">
          <%= if @current_user.role in [:admin, :soc_admin, :analyst] do %>
            <.menu_item
              icon_name="hero-bell"
              active?={@current_page == :alerts}
              path="/alerts"
              tooltip_txt={gettext("Alerts")}
            />
            <div class="w-full border border-neutral-500"></div>
          <% end %>

          <.menu_item
            icon_name="hero-document-duplicate"
            active?={@current_page == :cases}
            path="/"
            tooltip_txt={gettext("Cases")}
          />

          <%= if @current_user.role in [:admin, :team_admin, :soc_admin] do %>
            <div class="w-full border border-neutral-500"></div>
            <.menu_item
              icon_name="hero-users"
              active?={@current_page == :users}
              path="/users"
              tooltip_txt={gettext("Users")}
            />
            <%= if @current_user.role in [:admin, :soc_admin] do %>
              <div class="w-full border border-neutral-500"></div>
              <.menu_item
                icon_name="hero-building-office"
                active?={@current_page == :teams}
                path="/teams"
                tooltip_txt={gettext("Teams")}
              />
            <% end %>
          <% end %>
        </div>
        <!-- Bottom content -->
        <div class="flex-col w-full h-full justify-end items-center gap-4 inline-flex">
          <%= if @current_user.role == :admin do %>
            <.menu_item
              icon_name="hero-cog-8-tooth"
              active?={@current_page == :settings}
              path="/settings"
              tooltip_txt={gettext("Settings")}
            />
            <div class="w-full h-px border border-neutral-500"></div>
          <% end %>
          <.menu_item
            icon_name="hero-user-circle"
            active?={@current_page == :user}
            path="/user"
            tooltip_txt={gettext("Profile")}
          />
        </div>
      </div>
      <!-- The screen content -->
      <div class={["h-full w-full overflow-y-auto", @class]}>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  attr :icon_name, :string, required: true, doc: "name of hero icon used"
  attr :path, :string, default: nil, doc: "path to navigate to"
  attr :active?, :boolean, default: false, doc: "determines whether an item is highlighted"
  attr :tooltip_txt, :string, required: true, doc: "text displayed on tooltip when hovering"

  defp menu_item(%{icon_name: "hero-" <> _rest} = assigns) do
    assigns = assign(assigns, :selection_circle, @selection_circle)

    ~H"""
    <.link navigate={@path}>
      <.tooltip pos={:right} tooltip_label={@tooltip_txt}>
        <button class="bg-none border-none relative flex">
          <div :if={@active?} class={@selection_circle} />
          <.icon name={@icon_name} class="bg-white" />
        </button>
      </.tooltip>
    </.link>
    """
  end
end
