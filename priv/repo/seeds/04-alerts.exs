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
    company_id: random_company_id.(),
    additional_data: %{
      "ip_address" => "203.0.113.45",
      "location" => "Kyiv, Ukraine",
      "user_affected" => "john.smith@example.com",
      "failed_attempts" => 7,
      "success_time" => "2023-10-15T03:24:00Z",
      "device_type" => "Unknown Windows Device"
    }
  },
  %{
    alert_id: "ALERT-2023-002",
    title: "Malware Detection on Endpoint",
    description:
      "Trojan.Emotet detected on workstation DEV-LAPTOP-42. The malware has been quarantined but further investigation is required.",
    severity: :critical,
    creation_time: random_past_time.(2),
    link: "https://security-console.example.com/alerts/ALERT-2023-002",
    company_id: random_company_id.(),
    additional_data: %{
      "endpoint" => "DEV-LAPTOP-42",
      "malware_signature" => "Trojan.Emotet.Gen4",
      "user_affected" => "developer3@example.com",
      "quarantined_file" => "C:\\Users\\Developer\\Downloads\\invoice-3421.xls",
      "detection_method" => "Behavioral Analysis",
      "hash_sha256" => "e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855"
    }
  },
  %{
    alert_id: "ALERT-2023-003",
    title: "Data Exfiltration Attempt",
    description:
      "Unusual outbound traffic detected with sensitive data patterns. Large volume of data transferred to unrecognized external endpoint.",
    severity: :critical,
    creation_time: random_past_time.(5),
    link: "https://security-console.example.com/alerts/ALERT-2023-003",
    company_id: random_company_id.(),
    additional_data: %{
      "source_ip" => "10.0.24.56",
      "destination_ip" => "198.51.100.23",
      "data_volume" => "1.7GB",
      "detected_patterns" => ["SSN", "Credit Card", "Customer Database"],
      "protocol" => "HTTPS",
      "port" => 443,
      "duration" => "23 minutes",
      "files_count" => 247
    }
  },
  %{
    alert_id: "ALERT-2023-004",
    title: "Privilege Escalation Detected",
    description:
      "User account 'helpdesk2' modified group memberships to gain administrator privileges outside normal process.",
    severity: :high,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-004",
    company_id: random_company_id.(),
    additional_data: %{
      "username" => "helpdesk2",
      "added_groups" => ["Domain Admins", "Enterprise Admins"],
      "command_executed" => "Add-ADGroupMember -Identity 'Domain Admins' -Members 'helpdesk2'",
      "workstation" => "HELPDESK-PC12",
      "session_id" => "0x1234ABCD",
      "previous_privileges" => "Help Desk Operators",
      "time_of_escalation" => "2023-10-17T14:32:45Z"
    }
  },
  %{
    alert_id: "ALERT-2023-005",
    title: "Suspicious API Access",
    description: "Multiple high-volume API requests accessing customer records from unauthorized application.",
    severity: :medium,
    creation_time: random_past_time.(2),
    link: "https://security-console.example.com/alerts/ALERT-2023-005",
    company_id: random_company_id.(),
    additional_data: %{
      "api_endpoint" => "/api/v2/customers/records",
      "request_volume" => 4573,
      "client_id" => "mobile-app-beta",
      "authorized_apps" => ["crm-prod", "sales-portal"],
      "ip_ranges" => ["192.168.10.0/24", "10.50.30.0/24"],
      "rate" => "76.2 requests/second",
      "authentication_method" => "OAuth2",
      "investigation_notes" => "Confirmed as test by development team"
    }
  },
  %{
    alert_id: "ALERT-2023-006",
    title: "Ransomware IOCs Detected",
    description: "Network traffic matching known BlackCat/ALPHV ransomware command and control servers detected.",
    severity: :critical,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-006",
    company_id: random_company_id.(),
    additional_data: %{
      "c2_servers" => ["185.112.83.45", "192.87.134.12"],
      "affected_systems" => ["FILESERVER01", "DC-BACKUP"],
      "matched_signatures" => ["ALPHV.CnC.2023", "BlackCat.Beacon.TLS"],
      "traffic_pattern" => "Encrypted beaconing every 300 seconds",
      "dns_queries" => ["d34ddr0p.io", "l0ck3d0ut.net"],
      "first_seen" => "2023-10-19T02:15:33Z",
      "threat_intelligence_source" => "Mandiant"
    }
  },
  %{
    alert_id: "ALERT-2023-007",
    title: "Firewall Configuration Change",
    description: "Firewall rule added allowing inbound connections to database servers from public internet.",
    severity: :high,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-007",
    company_id: random_company_id.(),
    additional_data: %{
      "rule_id" => "fw-rule-7842",
      "modified_by" => "admin@example.com",
      "rule_details" => "ALLOW TCP ANY:ANY -> 10.0.12.0/24:3306",
      "change_ticket" => "None",
      "firewall_device" => "EDGE-FW-01",
      "previous_rule" => "DENY TCP ANY:ANY -> 10.0.12.0/24:3306",
      "config_backup" => "2023-10-18-0300-pre-change.cfg",
      "modification_method" => "Web Administration Console"
    }
  },
  %{
    alert_id: "ALERT-2023-008",
    title: "Phishing Campaign Detected",
    description:
      "Multiple users received similar phishing emails with malicious attachments claiming to be invoice documents.",
    severity: :medium,
    creation_time: random_past_time.(4),
    link: "https://security-console.example.com/alerts/ALERT-2023-008",
    company_id: random_company_id.(),
    additional_data: %{
      "affected_users" => 14,
      "email_subject" => "URGENT: Your invoice requires immediate payment",
      "sender_domain" => "invoice-billings.com",
      "attachment_type" => "xls with macros",
      "sender_ip" => "91.234.56.78",
      "spoofed_sender" => "accounting@legitimate-partner.com",
      "similar_campaigns" => "Observed at 3 other companies in finance sector",
      "email_body_snippet" =>
        "Please review the attached invoice and process payment within 24 hours to avoid penalties.",
      "phishing_score" => 9.2
    }
  },
  %{
    alert_id: "ALERT-2023-009",
    title: "Unauthorized Cloud Storage Access",
    description: "Sensitive S3 bucket accessed from unrecognized device and unusual location.",
    severity: :high,
    creation_time: random_past_time.(2),
    link: "https://security-console.example.com/alerts/ALERT-2023-009",
    company_id: random_company_id.(),
    additional_data: %{
      "bucket_name" => "example-corp-financial-reports",
      "user_identity" => "finance-admin@example.com",
      "location" => "Jakarta, Indonesia",
      "device_fingerprint" => "Unknown Windows Device",
      "api_calls" => ["ListObjects", "GetObject", "CopyObject"],
      "files_accessed" => 23,
      "total_data_retrieved" => "156 MB",
      "previous_login_location" => "New York, USA",
      "time_since_last_login" => "3 hours 24 minutes",
      "mfa_used" => false
    }
  },
  %{
    alert_id: "ALERT-2023-010",
    title: "Vulnerability Scanner Detection",
    description:
      "External IP address performing comprehensive port and vulnerability scanning against production environment.",
    severity: :medium,
    creation_time: random_past_time.(3),
    link: "https://security-console.example.com/alerts/ALERT-2023-010",
    company_id: random_company_id.(),
    additional_data: %{
      "scanner_ip" => "45.33.192.76",
      "scan_type" => "TCP SYN scan followed by service enumeration",
      "scan_duration" => "42 minutes",
      "targeted_services" => ["HTTPS", "SSH", "RDP", "SQL"],
      "ports_scanned" => [22, 80, 443, 3389, 1433, 3306],
      "packets_detected" => 14_253,
      "country_of_origin" => "Netherlands",
      "verification" => "Confirmed as authorized pentest by security team",
      "scan_tool_fingerprint" => "Nessus Professional 10.3.2"
    }
  },
  %{
    alert_id: "ALERT-2023-011",
    title: "Brute Force SSH Attempts",
    description: "Multiple failed SSH authentication attempts on development server from multiple source IPs.",
    severity: :medium,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-011",
    company_id: random_company_id.(),
    additional_data: %{
      "target_hostname" => "dev-srv-03",
      "target_ip" => "10.20.30.15",
      "failed_attempts" => 342,
      "username_patterns" => ["root", "admin", "ubuntu", "ec2-user"],
      "source_ips_count" => 17,
      "source_countries" => ["Russia", "China", "Brazil"],
      "time_window" => "Last 24 hours",
      "attack_pattern" => "Distributed, coordinated attempts"
    }
  },
  %{
    alert_id: "ALERT-2023-012",
    title: "Potential Data Exposure in GitHub Repository",
    description: "Secret scanning detected API keys and credentials committed to public GitHub repository.",
    severity: :high,
    creation_time: random_past_time.(1),
    link: "https://security-console.example.com/alerts/ALERT-2023-012",
    company_id: random_company_id.(),
    additional_data: %{
      "repository" => "example-corp/customer-portal",
      "committer" => "dev.jenkins@example.com",
      "commit_hash" => "a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2",
      "secrets_found" => ["AWS access key", "Database password", "API token"],
      "commit_message" => "Fixed configuration for staging environment",
      "exposure_duration" => "17 minutes",
      "public_views" => 3,
      "secret_locations" => ["config/database.yml", "src/main/resources/application.properties"]
    }
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
