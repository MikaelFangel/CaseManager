defmodule CaseManagerWeb.SearchBar do
  @moduledoc false

  use Phoenix.Component
  use Gettext, backend: CaseManagerWeb.Gettext

  import CaseManagerWeb.Input

  attr :action, :string, default: "search"
  attr :placeholder, :string, default: "Search"
  attr :value, :string, default: ""
  attr :class, :string, default: "hidden sm:inline"
  attr :input_class, :string, default: "!inline-block !w-fit"
  attr :rest, :global

  def search_bar(assigns) do
    ~H"""
    <form data-role="search" class={@class} phx-submit={@action}>
      <.input
        type="search"
        id="search"
        name="search"
        placeholder={@placeholder}
        value={@value}
        class={@input_class}
        {@rest}
      />
    </form>
    """
  end
end
