alias CaseManager.Accounts.User
alias CaseManager.Incidents.Case
alias CaseManager.Incidents.Comment
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

user = Enum.random(Ash.read!(User))

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

Ash.bulk_create!(cases, Case, :create, return_errors?: true, authorize?: false, actor: user)

# After creating the cases, add comments to them
cases = Ash.read!(Case, load: [:comments])

# Get users for assigning as comment authors
users = Ash.read!(User)

# Create comments for each case
Enum.each(cases, fn case ->
  # Create 2-4 comments per case
  comment_count = Enum.random(2..4)

  # Random comments based on case status and type
  comments =
    case case.status do
      :new ->
        [
          %{
            body: "Just started investigating this case. Will update soon.",
            visibility: :internal,
            case_id: case.id
          },
          %{
            body: "Looking at initial indicators. Gathering logs from affected systems.",
            visibility: :internal,
            case_id: case.id
          }
        ]

      :in_progress ->
        [
          %{
            body:
              "Initial analysis shows this could be #{if case.risk_level == :critical, do: "very serious", else: "concerning"}. Continuing investigation.",
            visibility: :internal,
            case_id: case.id
          },
          %{
            body:
              "Found evidence of #{if case.escalated, do: "lateral movement across three systems", else: "limited access to one system"}. Isolating affected machines.",
            visibility: :internal,
            case_id: case.id
          },
          %{
            body: "Customer has been notified about the ongoing investigation.",
            visibility: :public,
            case_id: case.id
          }
        ]

      :resolved ->
        [
          %{
            body:
              "Investigation complete. #{if case.resolution_type == :true_positive, do: "Confirmed security incident.", else: "Determined to be #{case.resolution_type}."}",
            visibility: :internal,
            case_id: case.id
          },
          %{
            body:
              "Remediation steps: #{if case.resolution_type == :true_positive, do: "Rebuilt affected systems and reset credentials.", else: "Updated monitoring rules to prevent false alerts."}",
            visibility: :internal,
            case_id: case.id
          },
          %{
            body: "Final report has been sent to the customer.",
            visibility: :public,
            case_id: case.id
          }
        ]

      _ ->
        [
          %{
            body: "Working through this case. Current status: #{case.status}",
            visibility: :internal,
            case_id: case.id
          },
          %{
            body: "Need additional log data to proceed. Requesting from customer.",
            visibility: :internal,
            case_id: case.id
          }
        ]
    end

  # Take a random subset if we want fewer than the default comments
  comments =
    if comment_count < length(comments) do
      Enum.take_random(comments, comment_count)
    else
      comments
    end

  # Create the comments using random users as actors
  Enum.each(comments, fn comment_attrs ->
    Ash.create!(Comment, comment_attrs, actor: Enum.random(users), authorize?: false)
  end)
end)

# Add some specific comments to notable cases
emotet_case = Enum.find(cases, fn c -> String.contains?(c.title, "Emotet") end)

if emotet_case do
  Ash.create!(
    Comment,
    %{
      body:
        "URGENT: Found evidence that Emotet has been present for 3 weeks. Attacker accessed finance share drive. Beginning incident response protocol.",
      visibility: :internal,
      case_id: emotet_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )
end

ransomware_case = Enum.find(cases, fn c -> String.contains?(c.title, "Ransomware") end)

if ransomware_case do
  Ash.create!(
    Comment,
    %{
      body: "Activating emergency response team. Isolating all affected systems from the network immediately.",
      visibility: :internal,
      case_id: ransomware_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )

  Ash.create!(
    Comment,
    %{
      body:
        "We are investigating a potential security incident. As a precaution, some systems may be temporarily unavailable.",
      visibility: :public,
      case_id: ransomware_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )
end
