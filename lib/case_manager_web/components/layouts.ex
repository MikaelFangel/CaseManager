defmodule CaseManagerWeb.Layouts do
  @moduledoc """
  This module holds different layouts used by your application.

  See the `layouts` directory for all templates available.
  The "root" layout is a skeleton rendered as part of the
  application router. The "app" layout is rendered as component
  in regular views and live views.
  """
  use CaseManagerWeb, :html

  embed_templates("layouts/*")

  attr :search_placeholder, :string, default: "Search..."
  attr :flash, :map

  slot :inner_block

  def app(assigns) do
    ~H"""
    <div class="flex flex-col h-screen">
      <.navbar search_placeholder={@search_placeholder} />

      <main class="flex-1 p-4 overflow-auto">
        <div class="mx-auto w-full space-y-4">
          {render_slot(@inner_block)}
        </div>
      </main>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  attr :search_placeholder, :string, default: "Search..."
  attr :left_width, :string, default: "w-1/2", doc: "Width class for left panel"
  attr :right_width, :string, default: "w-1/2", doc: "Width class for right panel"
  attr :flash, :map

  slot :top
  slot :left
  slot :right

  def split(assigns) do
    ~H"""
    <div class="flex flex-col h-screen">
      <.navbar search_placeholder={@search_placeholder} />

      <div class="p-4">
        {render_slot(@top)}
      </div>

      <div class="flex flex-1 overflow-hidden">
        <div class={"#{@left_width} overflow-auto"}>
          <div class="px-4 pb-4">
            {render_slot(@left)}
          </div>
        </div>
        <.divider horizontal={true} />
        <div class={"#{@right_width} overflow-auto flex"}>
          <div class="px-4 pb-4 flex-1">
            {render_slot(@right)}
          </div>
        </div>
      </div>

      <.flash_group flash={@flash} />
    </div>
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr(:flash, :map, required: true, doc: "the map of flash messages")
  attr(:id, :string, default: "flash-group", doc: "the optional id of flash container")

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash id="client-error" kind={:error} title={gettext("We can't find the internet")} phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")} phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})} hidden>
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 motion-safe:animate-spin" />
      </.flash>

      <.flash id="server-error" kind={:error} title={gettext("Something went wrong!")} phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")} phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})} hidden>
        {gettext("Hang in there while we get back on track")}
        <.icon name="hero-arrow-path" class="ml-1 h-3 w-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="card relative flex flex-row items-center border-2 border-base-300 bg-base-300 rounded-full">
      <div class="absolute w-[33%] h-full rounded-full border-1 border-base-200 bg-base-100 brightness-200 left-0 [[data-theme=light]_&]:left-[33%] [[data-theme=dark]_&]:left-[66%] transition-[left]" />

      <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "system"})} class="flex p-2">
        <.icon name="hero-computer-desktop-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "light"})} class="flex p-2">
        <.icon name="hero-sun-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>

      <button phx-click={JS.dispatch("phx:set-theme", detail: %{theme: "dark"})} class="flex p-2">
        <.icon name="hero-moon-micro" class="size-4 opacity-75 hover:opacity-100" />
      </button>
    </div>
    """
  end

  attr :search_placeholder, :string, default: "Search..."
  attr :on_search, :any, default: nil
  slot :nav_links

  def navbar(assigns) do
    ~H"""
    <header class="navbar shadow-sm px-4 sm:px-6 lg:px-8">
      <div class="flex-1">
        <a href="/" class="flex items-center gap-2">
          <img src={~p"/images/logo.svg"} width="36" />
          <span class="font-semibold">Defensive Shield</span>
        </a>
      </div>

      <div class="flex-none flex items-center gap-4">
        <ul class="menu menu-horizontal hidden sm:flex">
          <li><.link navigate={~p"/alert"}>Alerts</.link></li>
          <li><.link navigate={~p"/case"}>Cases</.link></li>
          <li><.link navigate={~p"/user"}>Users</.link></li>
        </ul>

        <form phx-submit={@on_search || "search"} class="form-control pt-2">
          <.input type="search" name="query" placeholder={@search_placeholder} value="" phx-debounce="300" class="join-item" />
        </form>

        <.theme_toggle />
      </div>
    </header>
    """
  end

  @doc """
    Provides a divider component

    ## Examples

      <.divider>

      <.divider horizontal={true} text_position="divider-end" divider_type={:warning}"> divide </.divider>
  """
  attr :horizontal, :boolean, default: false, doc: "Boolean to determine the divider orientation. defaults to vertical"
  attr :text_position, :string, default: "", doc: "String to determine the divider text position. defaults to middle"
  attr :divider_type, :atom, default: :neutral, doc: "Atom to determine the divider color. default to neutral"

  slot :inner_block

  def divider(assigns) do
    ~H"""
    <div class={"divider #{@horizontal && "divider-horizontal"} #{@text_position} divider-#{@divider_type}"}>{render_slot(@inner_block)}</div>
    """
  end
end
