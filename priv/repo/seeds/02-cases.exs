alias CaseManager.Incidents.Case
alias CaseManager.Organizations.Company
alias CaseManager.Organizations.SOC

require Ash.Query

Case
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

company_ids =
  Company
  |> Ash.read!()
  |> Enum.map(& &1.id)

soc_ids =
  SOC
  |> Ash.read!()
  |> Enum.map(& &1.id)

random_company_id = fn -> Enum.random(company_ids) end
random_soc_id = fn -> Enum.random(soc_ids) end

cases = [
  %{
    title: "Investigation of Suspicious Login Activity",
    description:
      "Multiple failed login attempts from Ukraine followed by successful login. Need to investigate if this is legitimate employee travel or credential compromise.",
    status: :open,
    risk_level: :high,
    escalated: false,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Emotet Malware Infection Incident",
    description:
      "Developer workstation infected with Emotet trojan. Need to investigate infection vector and potential lateral movement.",
    status: :in_progress,
    risk_level: :critical,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Data Exfiltration Investigation",
    description:
      "Large-scale data transfer containing sensitive patterns detected. Need to verify if authorized or malicious and identify data exposure scope.",
    status: :in_progress,
    risk_level: :critical,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Privilege Escalation Investigation",
    description:
      "Help desk account modified its own permissions to gain admin rights. Need to determine if this was malicious or an authorized emergency procedure.",
    status: :open,
    risk_level: :high,
    escalated: false,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Unauthorized API Usage Review",
    description:
      "Customer data accessed through API by unauthorized application. Need to determine appropriate access controls and potential data compromise.",
    status: :pending,
    risk_level: :medium,
    escalated: false,
    resolution_type: :benign,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "BlackCat Ransomware Detection",
    description:
      "Critical incident: Systems communicating with known BlackCat C2 servers. Potential active ransomware infection in progress.",
    status: :in_progress,
    risk_level: :critical,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Unauthorized Firewall Configuration Change",
    description:
      "Database servers exposed to internet due to unauthorized firewall rule change. Need to investigate intent and potential exploitation.",
    status: :resolved,
    risk_level: :high,
    escalated: true,
    resolution_type: :true_positive,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Corporate Phishing Campaign Analysis",
    description:
      "Multiple users targeted by sophisticated invoice-themed phishing. Need to assess impact and improve detection/prevention.",
    status: :closed,
    risk_level: :medium,
    escalated: false,
    resolution_type: :true_positive,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Cloud Storage Unauthorized Access",
    description:
      "Financial reports accessed from unusual location. Need to verify if compromise or legitimate travel by finance team member.",
    status: :resolved,
    risk_level: :high,
    escalated: false,
    resolution_type: :benign,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "External Vulnerability Scanning Investigation",
    description:
      "Production systems targeted by vulnerability scanner. Need to determine if penetration test, attack, or misconfguration.",
    status: :closed,
    risk_level: :medium,
    escalated: false,
    resolution_type: :false_positive,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "New Alert from EDR System",
    description:
      "Just received alert about potential command and control traffic from marketing department workstation.",
    status: :new,
    risk_level: :medium,
    escalated: false,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Web Server Authentication Bypass Attempt",
    description: "Multiple attempts to bypass authentication on the customer portal web server detected.",
    status: :pending,
    risk_level: :high,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Expired Certificate Incident",
    description: "Security alert generated when production website certificate expired causing customer access issues.",
    status: :reopened,
    risk_level: :medium,
    escalated: true,
    resolution_type: :inconclusive,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  }
]

Ash.bulk_create!(cases, Case, :create, return_errors?: true, authorize?: false)
