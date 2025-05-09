# Seeds for Security Operations Centers (SOCs)
#
# This seed file creates the SOCs that will be assigned to cases
# Run with: `mix run priv/repo/seeds/01-socs.exs`
# For cleanup only: `SEED_CLEAN_ONLY=true mix run priv/repo/seeds/01-socs.exs`

alias CaseManager.Organizations.SOC
alias CaseManager.Organizations.Company
alias CaseManager.Incidents.Case
alias CaseManager.Incidents.Alert
alias CaseManager.Incidents.Comment

require Ash.Query

# Check if we're in cleanup-only mode
clean_only = System.get_env("SEED_CLEAN_ONLY") == "true"

IO.puts("Cleaning existing comments, cases, alerts, companies, and SOCs...")

# Clean up all dependencies before creating SOCs
# First delete all comments (which might be linked to cases)
Comment
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Then delete all cases (which reference SOCs)
Case
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Then delete alerts
Alert
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Then delete companies (which may reference SOCs)
Company
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Now it's safe to delete existing SOCs
SOC
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Exit early if we're only cleaning
if clean_only do
  IO.puts("✅ Cleanup completed. Exiting without creating new data.")
  System.halt(0)
end

# Define SOC data
socs = [
  %{
    name: "Global Security Operations Center"
  },
  %{
    name: "CyberDefense Alliance SOC"
  },
  %{
    name: "Sentinel Security Services"
  },
  %{
    name: "BlueTeam Security Operations"
  },
  %{
    name: "Digital Guardian SOC"
  },
  %{
    name: "Cyberwatch Response Team"
  }
]

# Create SOCs in database
IO.puts("Creating #{length(socs)} SOCs...")
created_socs = Ash.bulk_create!(socs, SOC, :create, return_errors?: true, authorize?: false)
IO.puts("✅ SOCs created successfully")
