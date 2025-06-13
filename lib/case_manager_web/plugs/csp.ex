defmodule CaseManagerWeb.Plugs.CSP do
  @moduledoc """
  Content Security Policy (CSP) plug with essential security headers for Phoenix LiveView.
  """

  @behaviour Plug

  import Plug.Conn

  @nonce_length 24

  def init(_opts), do: []

  def call(conn, _opts) do
    nonce = generate_nonce()

    conn
    |> assign(:csp_nonce, nonce)
    |> put_csp_header(nonce)
    |> put_security_headers()
  end

  defp put_csp_header(conn, nonce) do
    csp_policy = build_csp_policy(nonce)
    put_resp_header(conn, "content-security-policy", csp_policy)
  end

  defp build_csp_policy(nonce) do
    Enum.join(
      [
        "default-src 'self'",
        "script-src 'self' 'nonce-#{nonce}'",
        "style-src 'self' 'nonce-#{nonce}'",
        "img-src 'self' data: blob:",
        "font-src 'self' data:",
        "connect-src 'self'",
        "object-src 'none'",
        "frame-ancestors 'none'",
        "base-uri 'self'",
        "form-action 'self'"
      ],
      "; "
    )
  end

  defp generate_nonce do
    @nonce_length
    |> :crypto.strong_rand_bytes()
    |> Base.encode64()
  end

  defp put_security_headers(conn) do
    conn
    |> put_resp_header("x-frame-options", "DENY")
    |> put_resp_header("x-content-type-options", "nosniff")
    |> put_resp_header("referrer-policy", "strict-origin-when-cross-origin")
    |> put_resp_header("cross-origin-opener-policy", "same-origin")
  end
end
