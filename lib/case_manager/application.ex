defmodule CaseManager.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CaseManagerWeb.Telemetry,
      CaseManager.Repo,
      {DNSCluster, query: Application.get_env(:case_manager, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CaseManager.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: CaseManager.Finch},
      {AshAuthentication.Supervisor, otp_app: :case_manager},
      # Start a worker by calling: CaseManager.Worker.start_link(arg)
      # {CaseManager.Worker, arg},
      # Start to serve requests, typically the last entry
      CaseManagerWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CaseManager.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CaseManagerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
