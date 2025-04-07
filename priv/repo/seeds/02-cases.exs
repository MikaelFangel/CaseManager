alias CaseManager.Incidents.Case

require Ash.Query

# Destroy all data
# Case
# |> Ash.read!()
# |> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

cases = [
  %{
    title: "Investigation of Suspicious Login Activity",
    description:
      "Multiple failed login attempts from Ukraine followed by successful login. Need to investigate if this is legitimate employee travel or credential compromise.",
    status: :open,
    priority: :high,
    escalated: false
  },
  %{
    title: "Emotet Malware Infection Incident",
    description:
      "Developer workstation infected with Emotet trojan. Need to investigate infection vector and potential lateral movement.",
    status: :in_progress,
    priority: :critical,
    escalated: true
  },
  %{
    title: "Data Exfiltration Investigation",
    description:
      "Large-scale data transfer containing sensitive patterns detected. Need to verify if authorized or malicious and identify data exposure scope.",
    status: :in_progress,
    priority: :critical,
    escalated: true
  },
  %{
    title: "Privilege Escalation Investigation",
    description:
      "Help desk account modified its own permissions to gain admin rights. Need to determine if this was malicious or an authorized emergency procedure.",
    status: :open,
    priority: :high,
    escalated: false
  },
  %{
    title: "Unauthorized API Usage Review",
    description:
      "Customer data accessed through API by unauthorized application. Need to determine appropriate access controls and potential data compromise.",
    status: :open,
    priority: :medium,
    escalated: false
  },
  %{
    title: "BlackCat Ransomware Detection",
    description:
      "Critical incident: Systems communicating with known BlackCat C2 servers. Potential active ransomware infection in progress.",
    status: :in_progress,
    priority: :critical,
    escalated: true
  },
  %{
    title: "Unauthorized Firewall Configuration Change",
    description:
      "Database servers exposed to internet due to unauthorized firewall rule change. Need to investigate intent and potential exploitation.",
    status: :resolved,
    priority: :high,
    escalated: true
  },
  %{
    title: "Corporate Phishing Campaign Analysis",
    description:
      "Multiple users targeted by sophisticated invoice-themed phishing. Need to assess impact and improve detection/prevention.",
    status: :closed,
    priority: :medium,
    escalated: false
  },
  %{
    title: "Cloud Storage Unauthorized Access",
    description:
      "Financial reports accessed from unusual location. Need to verify if compromise or legitimate travel by finance team member.",
    status: :resolved,
    priority: :high,
    escalated: false
  },
  %{
    title: "External Vulnerability Scanning Investigation",
    description:
      "Production systems targeted by vulnerability scanner. Need to determine if penetration test, attack, or misconfguration.",
    status: :closed,
    priority: :medium,
    escalated: false
  }
]

Ash.bulk_create!(cases, Case, :create, return_errors?: true, authorize?: false)
