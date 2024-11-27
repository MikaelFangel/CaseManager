defmodule CaseManagerWeb.Helpers do
  @moduledoc """
  Module that defines helper function for the web-based part of the application.
  """

  alias CaseManager.AppConfig.Setting

  @doc """
  Render basic HTML from text with markdown. All HTML tags are stripped before returning it as a raw value.
  """
  def render_markdown!(text) do
    text
    |> HtmlSanitizeEx.strip_tags()
    |> Earmark.as_html!()
    |> Phoenix.HTML.raw()
  end

  def load_bg do
    case Ash.get(Setting, %{key: "background"}) do
      {:ok, setting} -> hd(Ash.load!(setting, [:file]).file)
      {:error, _error} -> nil
    end
  end

  def load_logo do
    case Ash.get(Setting, %{key: "logo"}) do
      {:ok, setting} -> hd(Ash.load!(setting, [:file]).file)
      {:error, _error} -> nil
    end
  end
end
