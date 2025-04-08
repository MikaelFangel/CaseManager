alias CaseManager.Incidents.Alert

require Ash.Query

# Destroy all data
Alert
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

alerts = [
  %{
    alert_id: "ALERT-2025-001",
    title: "Suspicious Login Activity Detected",
    description: "Multiple failed login attempts followed by a successful login from an unusual location.",
    risk_level: :high,
    status: :new,
    creation_time: DateTime.truncate(DateTime.utc_now(), :second),
    link: "https://security-console.example.com/alerts/ALERT-2025-001",
    additional_data: %{
      "ip_address" => "203.0.113.45",
      "location" => "Kyiv, Ukraine",
      "user_affected" => "john.smith@example.com",
      "failed_attempts" => 7
    }
  },
  %{
    alert_id: "ALERT-2025-002",
    title: "Malware Detection on Endpoint",
    description:
      "Trojan.Emotet detected on workstation DEV-LAPTOP-42. The malware has been quarantined but further investigation is required.",
    risk_level: :critical,
    status: :reviewed,
    creation_time: DateTime.utc_now() |> DateTime.add(-2, :hour) |> DateTime.truncate(:second),
    link: "https://security-console.example.com/alerts/ALERT-2025-002",
    additional_data: %{
      "endpoint" => "DEV-LAPTOP-42",
      "malware_signature" => "Trojan.Emotet.Gen4",
      "user_affected" => "developer3@example.com",
      "quarantined_file" => "C:\\Users\\Developer\\Downloads\\invoice-3421.xls"
    }
  },
  %{
    alert_id: "ALERT-2025-003",
    title: "Data Exfiltration Attempt",
    description:
      "Unusual outbound traffic detected with sensitive data patterns. Large volume of data transferred to unrecognized external endpoint.",
    risk_level: :critical,
    status: :linked_to_case,
    creation_time: DateTime.utc_now() |> DateTime.add(-1, :day) |> DateTime.truncate(:second),
    link: "https://security-console.example.com/alerts/ALERT-2025-003",
    additional_data: %{
      "source_ip" => "10.0.24.56",
      "destination_ip" => "198.51.100.23",
      "data_volume" => "1.7GB",
      "detected_patterns" => ["SSN", "Credit Card", "Customer Database"]
    }
  },
  %{
    alert_id: "ALERT-2025-004",
    title: "Privilege Escalation Detected",
    description:
      "User account 'helpdesk2' modified group memberships to gain administrator privileges outside normal process.",
    risk_level: :high,
    status: :new,
    creation_time: DateTime.utc_now() |> DateTime.add(-6, :hour) |> DateTime.truncate(:second),
    link: "https://security-console.example.com/alerts/ALERT-2025-004",
    additional_data: %{
      "username" => "helpdesk2",
      "added_groups" => ["Domain Admins", "Enterprise Admins"],
      "command_executed" => "Add-ADGroupMember -Identity 'Domain Admins' -Members 'helpdesk2'"
    }
  },
  %{
    alert_id: "ALERT-2025-005",
    title: "Suspicious API Access",
    description: "Multiple high-volume API requests accessing customer records from unauthorized application.",
    risk_level: :medium,
    status: :false_positive,
    creation_time: DateTime.utc_now() |> DateTime.add(-12, :hour) |> DateTime.truncate(:second),
    link: "https://security-console.example.com/alerts/ALERT-2025-005",
    additional_data: %{
      "api_endpoint" => "/api/v2/customers/records",
      "request_volume" => 4573,
      "client_id" => "mobile-app-beta",
      "authorized_apps" => ["crm-prod", "sales-portal"]
    }
  },
  %{
    alert_id: "ALERT-2025-006",
    title: "Ransomware IOCs Detected",
    description: "Network traffic matching known BlackCat/ALPHV ransomware command and control servers detected.",
    risk_level: :critical,
    status: :reviewed,
    creation_time: DateTime.utc_now() |> DateTime.add(-30, :minute) |> DateTime.truncate(:second),
    link: "https://security-console.example.com/alerts/ALERT-2025-006",
    additional_data: %{
      "c2_servers" => ["185.112.83.45", "192.87.134.12"],
      "affected_systems" => ["FILESERVER01", "DC-BACKUP"],
      "matched_signatures" => ["ALPHV.CnC.2023", "BlackCat.Beacon.TLS"]
    }
  },
  %{
    alert_id: "ALERT-2025-007",
    title: "Firewall Configuration Change",
    description: "Firewall rule added allowing inbound connections to database servers from public internet.",
    risk_level: :high,
    status: :linked_to_case,
    creation_time: DateTime.utc_now() |> DateTime.add(-3, :hour) |> DateTime.truncate(:second),
    link: "https://security-console.example.com/alerts/ALERT-2025-007",
    additional_data: %{
      "rule_id" => "fw-rule-7842",
      "modified_by" => "admin@example.com",
      "rule_details" => "ALLOW TCP ANY:ANY -> 10.0.12.0/24:3306",
      "change_ticket" => "None"
    }
  },
  %{
    alert_id: "ALERT-2025-008",
    title: "Phishing Campaign Detected",
    description:
      "Multiple users received similar phishing emails with malicious attachments claiming to be invoice documents.",
    risk_level: :medium,
    status: :new,
    creation_time: DateTime.utc_now() |> DateTime.add(-2, :day) |> DateTime.truncate(:second),
    link: "https://security-console.example.com/alerts/ALERT-2025-008",
    additional_data: %{
      "affected_users" => 14,
      "email_subject" => "URGENT: Your invoice requires immediate payment",
      "sender_domain" => "invoice-billings.com",
      "attachment_type" => "xls with macros"
    }
  },
  %{
    alert_id: "ALERT-2025-009",
    title: "Unauthorized Cloud Storage Access",
    description: "Sensitive S3 bucket accessed from unrecognized device and unusual location.",
    risk_level: :high,
    status: :reviewed,
    creation_time: DateTime.utc_now() |> DateTime.add(-4, :hour) |> DateTime.truncate(:second),
    link: "https://security-console.example.com/alerts/ALERT-2025-009",
    additional_data: %{
      "bucket_name" => "example-corp-financial-reports",
      "user_identity" => "finance-admin@example.com",
      "location" => "Jakarta, Indonesia",
      "device_fingerprint" => "Unknown Windows Device"
    }
  },
  %{
    alert_id: "ALERT-2025-010",
    title: "Vulnerability Scanner Detection",
    description:
      "External IP address performing comprehensive port and vulnerability scanning against production environment.",
    risk_level: :medium,
    status: :false_positive,
    creation_time: DateTime.utc_now() |> DateTime.add(-8, :hour) |> DateTime.truncate(:second),
    link: "https://security-console.example.com/alerts/ALERT-2025-010",
    additional_data: %{
      "scanner_ip" => "45.33.192.76",
      "scan_type" => "TCP SYN scan followed by service enumeration",
      "scan_duration" => "42 minutes",
      "targeted_services" => ["HTTPS", "SSH", "RDP", "SQL"]
    }
  }
]

Ash.bulk_create!(alerts, Alert, :create, return_errors?: true, authorize?: false)
