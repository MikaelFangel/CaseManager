defmodule CaseManagerWeb.Helpers do
  @moduledoc """
  Module that defines helper function for the web-based part of the application.
  """

  alias CaseManager.Configuration.Setting

  @doc """
  Render basic HTML from text with markdown. All HTML tags are stripped before returning it as a raw value.
  """
  def render_markdown!(text) do
    text
    |> HtmlSanitizeEx.strip_tags()
    |> Earmark.as_html!()
    |> Phoenix.HTML.raw()
  end

  @doc """
  Retrieves the background image from the database. If the image isn't set in the datbase
  this function returns nil. This is to allow to use :if={@image} to check if this settings has been set.
  """
  def load_bg do
    case Ash.get(Setting, %{key: "background"}) do
      {:ok, setting} -> hd(Ash.load!(setting, [:file]).file)
      {:error, _error} -> nil
    end
  end

  @doc """
  Retrieves the logo from the database. If the logo isn't set in the datbase
  this function returns nil. This is to allow to use :if={@logo} to check if this settings has been set.
  """
  def load_logo do
    case Ash.get(Setting, %{key: "logo"}) do
      {:ok, setting} -> hd(Ash.load!(setting, [:file]).file)
      {:error, _error} -> nil
    end
  end
end
