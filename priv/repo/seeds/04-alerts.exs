# Seeds for Alert records
#
# This seed file creates security alerts that can be linked to cases
# Run with: `mix run priv/repo/seeds/04-alerts.exs`
# For cleanup only: `SEED_CLEAN_ONLY=true mix run priv/repo/seeds/04-alerts.exs`

alias CaseManager.Accounts.User
alias CaseManager.Incidents.Alert
alias CaseManager.Incidents.Comment
alias CaseManager.Organizations.Company

require Ash.Query

# Check if we're in cleanup-only mode
clean_only = System.get_env("SEED_CLEAN_ONLY") == "true"

# Clean up existing alerts before creating new ones
IO.puts("Cleaning existing alerts...")

Alert
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Get all company IDs to assign alerts randomly
company_ids =
  Company
  |> Ash.read!()
  |> Enum.map(& &1.id)

random_company_id = fn -> Enum.random(company_ids) end

# Helper function to generate random past timestamps
random_past_time = fn max_days_ago ->
  days_ago = :rand.uniform(max_days_ago)
  hours_ago = :rand.uniform(24)
  minutes_ago = :rand.uniform(60)

  DateTime.utc_now()
  |> DateTime.add(-days_ago, :day)
  |> DateTime.add(-hours_ago, :hour)
  |> DateTime.add(-minutes_ago, :minute)
  |> DateTime.truncate(:second)
end

# Define alert data with various types, statuses, and Severitys
alerts = [
  %{
    alert_id: "ALERT-2023-001",
    title: "Suspicious Login Activity Detected",
    description: "Multiple failed login attempts followed by a successful login from an unusual location.",
    severity: :high,
    creation_time: random_past_time.(3),
    link: "https://security-console.example.com/alerts/ALERT-2023-001",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-002",
    title: "Malware Detection on Endpoint",
    description:
      "Trojan.Emotet detected on workstation DEV-LAPTOP-42. The malware has been quarantined but further investigation is required.",
    severity: :critical,
    creation_time: random_past_time.(2),
    link: "https://security-console.example.com/alerts/ALERT-2023-002",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-003",
    title: "Data Exfiltration Attempt",
    description:
      "Unusual outbound traffic detected with sensitive data patterns. Large volume of data transferred to unrecognized external endpoint.",
    severity: :critical,
    creation_time: random_past_time.(5),
    link: "https://security-console.example.com/alerts/ALERT-2023-003",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-004",
    title: "Privilege Escalation Detected",
    description:
      "User account 'helpdesk2' modified group memberships to gain administrator privileges outside normal process.",
    severity: :high,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-004",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-005",
    title: "Suspicious API Access",
    description: "Multiple high-volume API requests accessing customer records from unauthorized application.",
    severity: :medium,
    creation_time: random_past_time.(2),
    link: "https://security-console.example.com/alerts/ALERT-2023-005",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-006",
    title: "Ransomware IOCs Detected",
    description: "Network traffic matching known BlackCat/ALPHV ransomware command and control servers detected.",
    severity: :critical,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-006",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-007",
    title: "Firewall Configuration Change",
    description: "Firewall rule added allowing inbound connections to database servers from public internet.",
    severity: :high,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-007",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-008",
    title: "Phishing Campaign Detected",
    description:
      "Multiple users received similar phishing emails with malicious attachments claiming to be invoice documents.",
    severity: :medium,
    creation_time: random_past_time.(4),
    link: "https://security-console.example.com/alerts/ALERT-2023-008",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-009",
    title: "Unauthorized Cloud Storage Access",
    description: "Sensitive S3 bucket accessed from unrecognized device and unusual location.",
    severity: :high,
    creation_time: random_past_time.(2),
    link: "https://security-console.example.com/alerts/ALERT-2023-009",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-010",
    title: "Vulnerability Scanner Detection",
    description:
      "External IP address performing comprehensive port and vulnerability scanning against production environment.",
    severity: :medium,
    creation_time: random_past_time.(3),
    link: "https://security-console.example.com/alerts/ALERT-2023-010",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-011",
    title: "Brute Force SSH Attempts",
    description: "Multiple failed SSH authentication attempts on development server from multiple source IPs.",
    severity: :medium,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-011",
    company_id: random_company_id.()
  },
  %{
    alert_id: "ALERT-2023-012",
    title: "Potential Data Exposure in GitHub Repository",
    description: "Secret scanning detected API keys and credentials committed to public GitHub repository.",
    severity: :high,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-012",
    company_id: random_company_id.()
  }
]

# Exit early if we're only cleaning
if clean_only do
  IO.puts("✅ Cleanup completed. Exiting without creating new data.")
  System.halt(0)
end

# Create alerts in database
IO.puts("Creating #{length(alerts)} alerts...")
Ash.bulk_create!(alerts, Alert, :create, return_errors?: true, authorize?: false)
IO.puts("✅ Alerts created successfully")

# Now add comments to some of the alerts
IO.puts("Adding comments to alerts...")

# Get users for assigning as comment authors
users = Ash.read!(User)

# Get all alerts to add comments to
all_alerts = Ash.read!(Alert)

# Function to create a comment with random user
create_alert_comment = fn alert, body, visibility ->
  # Use direct creation of a comment linked to the alert
  random_user = Enum.random(users)

  # Create the comment directly using the Comment resource
  comment =
    Ash.create!(
      Comment,
      %{
        body: body,
        visibility: visibility,
        alert_id: alert.id
      },
      actor: random_user,
      authorize?: false
    )

  # Log comment creation for debugging
  IO.puts("Created #{visibility} comment for alert #{alert.alert_id}: #{String.slice(body, 0, 30)}...")

  # Return the created comment
  comment
end

# Add comments to all alerts with different visibility levels
IO.puts("\nAdding comments to #{length(all_alerts)} alerts...\n")

Enum.each(all_alerts, fn alert ->
  IO.puts("Processing alert #{alert.alert_id} (#{alert.title})...")
  # Ensure each alert gets all three visibility types
  Enum.each([:internal, :public, :personal], fn visibility ->
    # Pick 1-2 comments of each visibility type
    comment_count = Enum.random(1..2)

    Enum.each(1..comment_count, fn _ ->
      body =
        case visibility do
          :internal ->
            Enum.random([
              "Internal note: This alert matches pattern we've seen at #{Enum.random(2..5)} other clients recently.",
              "Need to escalate this to senior analyst team for review. Potential false positive.",
              "Checked with engineering - this is related to the maintenance window from last week.",
              "Following standard playbook ALC-234 for this type of alert.",
              "Initial triage indicates this is a #{alert.severity} priority issue.",
              "Correlating with similar events from the past 30 days to identify patterns."
            ])

          :public ->
            Enum.random([
              "We're investigating this alert and will provide updates shortly.",
              "This has been confirmed as actionable. Customer has been notified.",
              "Working with the customer's IT team to gather more information.",
              "Resolution plan has been communicated to stakeholders.",
              "Customer acknowledged receipt of the alert notification.",
              "Per procedure, this will require coordination with the customer's IT team."
            ])

          :personal ->
            Enum.random([
              "Reminder to myself: Check the updated threat intel feed for this indicator.",
              "Need to follow up with Jim about similar case from last month.",
              "Added to my dashboard for follow-up tomorrow morning.",
              "Making a note to compare with the database dump from case #45921.",
              "This looks similar to what we saw in the finance sector last quarter.",
              "Going to review the latest threat intel report for related indicators."
            ])
        end

      create_alert_comment.(alert, body, visibility)
    end)
  end)

  # Add a status update based on the alert's status (with debug output)
  IO.puts("  Adding status comment for alert #{alert.alert_id} (status: #{alert.status})...")

  status_comment =
    case alert.status do
      :new ->
        {
          "New alert received - beginning initial triage.",
          :internal
        }

      :reviewed ->
        {
          "Review completed: This alert requires additional investigation.",
          :internal
        }

      :false_positive ->
        {
          "After thorough investigation, this alert has been determined to be a false positive.",
          :public
        }

      :linked_to_case ->
        {
          "This alert has been linked to an active case for further investigation.",
          :internal
        }

      _ ->
        {
          "Alert status updated to: #{alert.status}",
          :internal
        }
    end

  {body, visibility} = status_comment
  create_alert_comment.(alert, body, visibility)
end)

alert_count = length(all_alerts)
IO.puts("\n✅ Alert comments created successfully (added comments to #{alert_count} alerts)")

# Verify comment counts by alert
verified_alerts = Alert |> Ash.Query.load(:comments) |> Ash.read!()
total_comment_count = 0

Enum.each(verified_alerts, fn alert ->
  comment_count = length(alert.comments)
  total_comment_count = total_comment_count + comment_count

  if comment_count > 0 do
    internal_count = alert.comments |> Enum.filter(fn c -> c.visibility == :internal end) |> length()
    public_count = alert.comments |> Enum.filter(fn c -> c.visibility == :public end) |> length()
    personal_count = alert.comments |> Enum.filter(fn c -> c.visibility == :personal end) |> length()

    IO.puts(
      "  Alert #{alert.alert_id}: #{comment_count} comments (#{internal_count} internal, #{public_count} public, #{personal_count} personal)"
    )
  else
    IO.puts("  ⚠️  Alert #{alert.alert_id}: No comments found!")
  end
end)

IO.puts("\nTotal comments created: #{total_comment_count}")
