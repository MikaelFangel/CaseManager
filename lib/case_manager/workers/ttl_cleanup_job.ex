defmodule CaseManager.Workers.TTLCleanup do
  @moduledoc """
  GDPR compliance job that destroys alerts and cases older than 6 months.

  Automatically scheduled to run daily at 2 AM UTC via Oban.Cron.
  Processes records in chunks to avoid database timeouts.
  """

  use Oban.Worker,
    queue: :ttl_cleanup,
    max_attempts: 3

  alias CaseManager.Incidents

  require Logger

  # Process in chunks to avoid database timeouts
  @chunk_size 500

  @impl Oban.Worker
  def perform(%Oban.Job{}) do
    Logger.info("Starting TTL cleanup for GDPR compliance...")

    start_time = System.monotonic_time(:millisecond)

    # Process alerts and cases
    {:ok, alert_results} = cleanup_old_alerts()
    {:ok, case_results} = cleanup_old_cases()

    end_time = System.monotonic_time(:millisecond)
    duration = end_time - start_time

    # Log results for audit trail
    _total_deleted = alert_results.deleted + case_results.deleted

    Logger.info(
      "TTL cleanup completed in #{duration}ms: #{alert_results.deleted} alerts, #{case_results.deleted} cases deleted"
    )

    # Log for GDPR audit trail
    log_gdpr_compliance(alert_results, case_results, duration)

    :ok
  rescue
    error ->
      Logger.error("TTL cleanup failed: #{inspect(error)}")
      {:error, error}
  end

  @doc """
  Manually trigger TTL cleanup (for emergency use or testing)
  """
  def trigger_cleanup do
    %{}
    |> __MODULE__.new(priority: 3, queue: :ttl_cleanup)
    |> Oban.insert()
  end

  defp cleanup_old_alerts do
    Logger.info("Starting cleanup of alerts older than 6 months...")

    old_alerts = Incidents.list_old_alerts!(6, :month, authorize?: false)
    total_alerts = length(old_alerts)

    if total_alerts == 0 do
      Logger.info("No alerts older than 6 months found")
      {:ok, %{found: 0, deleted: 0, chunks: 0, errors: 0}}
    else
      Logger.info("Found #{total_alerts} alerts to delete")

      chunks = Enum.chunk_every(old_alerts, @chunk_size)

      results =
        Enum.reduce(chunks, %{deleted: 0, errors: 0}, fn chunk, acc ->
          chunk_result = delete_alert_chunk(chunk)

          %{
            deleted: acc.deleted + chunk_result.deleted,
            errors: acc.errors + chunk_result.errors
          }
        end)

      {:ok, Map.merge(results, %{found: total_alerts, chunks: length(chunks)})}
    end
  end

  defp cleanup_old_cases do
    Logger.info("Starting cleanup of cases older than 6 months...")

    old_cases = Incidents.list_old_cases!(6, :month, authorize?: false)
    total_cases = length(old_cases)

    if total_cases == 0 do
      Logger.info("No cases older than 6 months found")
      {:ok, %{found: 0, deleted: 0, chunks: 0, errors: 0}}
    else
      Logger.info("Found #{total_cases} cases to delete")

      chunks = Enum.chunk_every(old_cases, @chunk_size)

      results =
        Enum.reduce(chunks, %{deleted: 0, errors: 0}, fn chunk, acc ->
          chunk_result = delete_case_chunk(chunk)

          %{
            deleted: acc.deleted + chunk_result.deleted,
            errors: acc.errors + chunk_result.errors
          }
        end)

      {:ok, Map.merge(results, %{found: total_cases, chunks: length(chunks)})}
    end
  end

  defp delete_alert_chunk(alerts) do
    Enum.reduce(alerts, %{deleted: 0, errors: 0}, fn alert, acc ->
      case Incidents.delete_alert(alert, authorize?: false) do
        :ok ->
          %{deleted: acc.deleted + 1, errors: acc.errors}

        {:error, error} ->
          Logger.error("Failed to delete alert #{alert.id}: #{inspect(error)}")
          %{deleted: acc.deleted, errors: acc.errors + 1}
      end
    end)
  end

  defp delete_case_chunk(cases) do
    Enum.reduce(cases, %{deleted: 0, errors: 0}, fn case_record, acc ->
      case Incidents.delete_case(case_record, authorize?: false) do
        :ok ->
          %{deleted: acc.deleted + 1, errors: acc.errors}

        {:error, error} ->
          Logger.error("Failed to delete case #{case_record.id}: #{inspect(error)}")
          %{deleted: acc.deleted, errors: acc.errors + 1}
      end
    end)
  end

  defp log_gdpr_compliance(alert_results, case_results, duration_ms) do
    timestamp = DateTime.to_iso8601(DateTime.utc_now())

    compliance_log = %{
      timestamp: timestamp,
      duration_ms: duration_ms,
      alerts: %{
        found: alert_results.found,
        deleted: alert_results.deleted,
        errors: alert_results.errors,
        chunks: alert_results.chunks
      },
      cases: %{
        found: case_results.found,
        deleted: case_results.deleted,
        errors: case_results.errors,
        chunks: case_results.chunks
      },
      total_deleted: alert_results.deleted + case_results.deleted,
      total_errors: alert_results.errors + case_results.errors
    }

    # Log in structured format for audit trails
    Logger.info("GDPR_COMPLIANCE_AUDIT: #{Jason.encode!(compliance_log)}")

    # Alert if there were errors
    if compliance_log.total_errors > 0 do
      Logger.warning("GDPR cleanup completed with #{compliance_log.total_errors} errors - manual review required")
    end
  end
end
