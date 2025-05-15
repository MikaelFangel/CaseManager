# Seeds for Case records and Case Comments
#
# This seed file creates security cases and associated comments.
# This should run after users, companies, and SOCs have been created.
# Run with: `mix run priv/repo/seeds/05-cases.exs`
# For cleanup only: `SEED_CLEAN_ONLY=true mix run priv/repo/seeds/05-cases.exs`

alias CaseManager.Accounts.User
alias CaseManager.Incidents.Case
alias CaseManager.Incidents.Comment
alias CaseManager.Organizations.Company
alias CaseManager.Organizations.SOC

require Ash.Query

# Check if we're in cleanup-only mode
clean_only = System.get_env("SEED_CLEAN_ONLY") == "true"

# Clean up existing data before creating new ones
# First delete case comments (preserving alert comments), then cases to avoid dependency issues
IO.puts("Cleaning existing case comments...")

Comment
|> Ash.Query.filter(not is_nil(case_id))
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

Case
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Exit early if we're only cleaning
if clean_only do
  IO.puts("✅ Cleanup completed. Exiting without creating new data.")
  System.halt(0)
end

# Get all company and SOC IDs to assign cases randomly
company_ids =
  Company
  |> Ash.read!()
  |> Enum.map(& &1.id)

soc_ids =
  SOC
  |> Ash.read!()
  |> Enum.map(& &1.id)

# Get a random user as the default actor for case creation
user = Enum.random(Ash.read!(User))

# Helper functions for random assignment
random_company_id = fn -> Enum.random(company_ids) end
random_soc_id = fn -> Enum.random(soc_ids) end

# Define case data with various statuses, Severitys, and descriptions
cases = [
  %{
    title: "Investigation of Suspicious Login Activity",
    description:
      "Multiple failed login attempts from Ukraine followed by successful login. Need to investigate if this is legitimate employee travel or credential compromise.",
    status: :open,
    severity: :high,
    escalated: false,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Emotet Malware Infection Incident",
    description:
      "Developer workstation infected with Emotet trojan. Need to investigate infection vector and potential lateral movement.",
    status: :in_progress,
    severity: :critical,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Data Exfiltration Investigation",
    description:
      "Large-scale data transfer containing sensitive patterns detected. Need to verify if authorized or malicious and identify data exposure scope.",
    status: :in_progress,
    severity: :critical,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Privilege Escalation Investigation",
    description:
      "Help desk account modified its own permissions to gain admin rights. Need to determine if this was malicious or an authorized emergency procedure.",
    status: :open,
    severity: :high,
    escalated: false,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Unauthorized API Usage Review",
    description:
      "Customer data accessed through API by unauthorized application. Need to determine appropriate access controls and potential data compromise.",
    status: :pending,
    severity: :medium,
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
    severity: :critical,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Unauthorized Firewall Configuration Change",
    description:
      "Database servers exposed to internet due to unauthorized firewall rule change. Need to investigate intent and potential exploitation.",
    status: :resolved,
    severity: :high,
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
    severity: :medium,
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
    severity: :high,
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
    severity: :medium,
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
    severity: :medium,
    escalated: false,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Web Server Authentication Bypass Attempt",
    description: "Multiple attempts to bypass authentication on the customer portal web server detected.",
    status: :pending,
    severity: :high,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Expired Certificate Incident",
    description: "Security alert generated when production website certificate expired causing customer access issues.",
    status: :reopened,
    severity: :medium,
    escalated: true,
    resolution_type: :inconclusive,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "DDoS Attack on Corporate Website",
    description:
      "Distributed denial of service attack targeting the main corporate website. Traffic volume exceeding normal by 500%.",
    status: :in_progress,
    severity: :high,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  },
  %{
    title: "Supply Chain Software Compromise",
    description:
      "Third-party software component found to contain backdoor. Need to identify affected systems and potential exploitation.",
    status: :open,
    severity: :critical,
    escalated: true,
    company_id: random_company_id.(),
    soc_id: random_soc_id.()
  }
]

# Create the cases in the database
IO.puts("Creating #{length(cases)} cases...")
created_cases = Ash.bulk_create!(cases, Case, :create, return_errors?: true, authorize?: false, actor: user)
IO.puts("✅ Cases created successfully")

# After creating the cases, add comments to them
IO.puts("Adding comments to cases...")
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
          },
          %{
            body: "Reminder to myself: Need to check similar incidents from last month.",
            visibility: :personal,
            case_id: case.id
          }
        ]

      :in_progress ->
        [
          %{
            body:
              "Initial analysis shows this could be #{if case.severity == :critical, do: "very serious", else: "concerning"}. Continuing investigation.",
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
          },
          %{
            body: "Personal note: I've seen this attack pattern before. Checking my archived notes from that case.",
            visibility: :personal,
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
          },
          %{
            body: "Note to self: Follow up with customer next week to verify everything is still working correctly.",
            visibility: :personal,
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
          },
          %{
            body: "My thoughts: This alert pattern seems unusual. Need to dig deeper into the network flows.",
            visibility: :personal,
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

  # Add some random personal comments to each case
  personal_comments = [
    "Adding this case to my priority list for tomorrow.",
    "Reminds me of that case from last quarter - should review those notes.",
    "Need to talk to the threat intel team about this indicator privately.",
    "I think I've seen this attacker's TTPs before in another case.",
    "Following my own checklist for this type of incident.",
    "Going to do some extra research on this attack vector tonight."
  ]

  # Randomly add a personal comment
  comments =
    if Enum.random(1..2) == 1 do
      personal_comment = %{
        body: Enum.random(personal_comments),
        visibility: :personal,
        case_id: case.id
      }

      [personal_comment | comments]
    else
      comments
    end

  # Create the comments using random users as actors
  Enum.each(comments, fn comment_attrs ->
    Ash.create!(Comment, comment_attrs, actor: Enum.random(users), authorize?: false)
  end)
end)

# Add some specific comments to notable cases with more detailed information
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

  Ash.create!(
    Comment,
    %{
      body:
        "Personal note: I need to check if my other clients are vulnerable to this Emotet variant. This strain looks similar to what I saw at FinCorp last month.",
      visibility: :personal,
      case_id: emotet_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )

  Ash.create!(
    Comment,
    %{
      body:
        "Initial investigation shows the infection vector was a phishing email with macro-enabled Excel attachment. User reports opening file from accounting@trusted-partner.com that contained invoice details.",
      visibility: :internal,
      case_id: emotet_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )

  Ash.create!(
    Comment,
    %{
      body:
        "FORENSIC UPDATE: Malware established persistence via scheduled task and registry keys. Found evidence of credential harvesting and lateral movement attempts to HR and finance systems.",
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
        "This is the third BlackCat case I've worked this month. Starting to see patterns in initial access. Need to document this for myself.",
      visibility: :personal,
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

  Ash.create!(
    Comment,
    %{
      body:
        "CRITICAL UPDATE: Confirmed BlackCat/ALPHV ransomware deployment on three file servers. Detected file encryption in progress on FILESERVER01. Triggering full network isolation and DR protocols.",
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
        "IR Team deployed EDR rollout to all systems. Found ransomware binary at C:\\Windows\\Temp\\svc64.exe with BlackCat signatures. Initial infection vector appears to be compromised admin credentials.",
      visibility: :internal,
      case_id: ransomware_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )
end

# Add specific comments to supply chain case
supply_chain_case = Enum.find(cases, fn c -> String.contains?(c.title, "Supply Chain") end)

if supply_chain_case do
  Ash.create!(
    Comment,
    %{
      body:
        "ALERT: Vendor disclosed critical vulnerability in LogProcessor library v2.3.4-2.4.1 used in our application stack. Contains hardcoded backdoor credential.",
      visibility: :internal,
      case_id: supply_chain_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )

  Ash.create!(
    Comment,
    %{
      body:
        "Private research note: This looks similar to the SolarWinds attack methodology. Planning to write up a comparison for my personal knowledge base.",
      visibility: :personal,
      case_id: supply_chain_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )

  Ash.create!(
    Comment,
    %{
      body:
        "Initial scan shows 17 applications using vulnerable component. Prioritizing production systems for emergency patching. No evidence of exploitation yet.",
      visibility: :internal,
      case_id: supply_chain_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )
end

# Add comments to the DDoS case
ddos_case = Enum.find(cases, fn c -> String.contains?(c.title, "DDoS") end)

if ddos_case do
  Ash.create!(
    Comment,
    %{
      body:
        "Attack traffic analysis: Layer 7 HTTP flood targeting login and checkout APIs. Traffic originating from ~2,000 unique IPs across 40 countries. Signature matches DDoS-as-a-Service provider.",
      visibility: :internal,
      case_id: ddos_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )

  Ash.create!(
    Comment,
    %{
      body:
        "Reminder: Need to check my notes on that DDoS mitigation webinar from last month. Pretty sure they mentioned this exact botnet pattern.",
      visibility: :personal,
      case_id: ddos_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )

  Ash.create!(
    Comment,
    %{
      body:
        "CDN mitigation rules deployed and working. Rate limiting and geo-blocking implemented. Traffic normal at edge but origin servers still seeing intermittent availability issues.",
      visibility: :internal,
      case_id: ddos_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )

  Ash.create!(
    Comment,
    %{
      body:
        "Our website is currently experiencing technical difficulties. Our team is working to restore full service. We appreciate your patience.",
      visibility: :public,
      case_id: ddos_case.id
    },
    actor: Enum.random(users),
    authorize?: false
  )
end

IO.puts("✅ Case comments created successfully")
IO.puts("All seed data has been loaded successfully!")
