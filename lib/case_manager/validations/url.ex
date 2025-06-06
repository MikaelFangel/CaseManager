defmodule CaseManager.Validations.Url do
  @moduledoc """
  Validates that an attribute contains a valid HTTP/HTTPS URL.

  This validation ensures the URL has a proper scheme (http/https),
  a valid host, and can be parsed correctly.

  ## Example

      validate {CaseManager.Validations.Url,
        attribute: :link,
        message: "must be a valid URL"
      }
  """
  use Ash.Resource.Validation

  @impl true
  def init(opts) do
    if is_atom(opts[:attribute]) do
      {:ok, opts}
    else
      {:error, "attribute must be an atom"}
    end
  end

  @impl true
  def validate(changeset, opts, _context) do
    attribute = opts[:attribute]
    value = Ash.Changeset.get_attribute(changeset, attribute)

    case validate_url(value) do
      :ok ->
        :ok

      {:error, reason} ->
        message = opts[:message] || get_default_message(reason)
        {:error, field: attribute, message: message}
    end
  end

  defp validate_url(nil), do: :ok
  defp validate_url(""), do: :ok

  defp validate_url(url) when is_binary(url) do
    case URI.parse(url) do
      %URI{scheme: scheme, host: host} when scheme in ["http", "https"] and not is_nil(host) ->
        validate_host(host)

      %URI{scheme: scheme} when scheme not in ["http", "https"] ->
        {:error, :invalid_scheme}

      %URI{host: nil} ->
        {:error, :missing_host}

      _error ->
        {:error, :invalid_format}
    end
  end

  defp validate_url(_other), do: {:error, :not_string}

  defp validate_host(host) when is_binary(host) do
    if String.trim(host) == "" do
      {:error, :empty_host}
    else
      :ok
    end
  end

  defp get_default_message(:invalid_scheme), do: "must use HTTP or HTTPS protocol"
  defp get_default_message(:missing_host), do: "must have a valid hostname"
  defp get_default_message(:empty_host), do: "hostname cannot be empty"
  defp get_default_message(:invalid_format), do: "must be a valid URL format"
  defp get_default_message(:not_string), do: "must be a string"
end
