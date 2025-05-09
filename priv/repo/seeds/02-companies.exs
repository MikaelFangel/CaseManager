# Seeds for Company records
#
# This seed file creates the companies that are clients of SOCs and sources of alerts
# Run with: `mix run priv/repo/seeds/02-companies.exs`
# For cleanup only: `SEED_CLEAN_ONLY=true mix run priv/repo/seeds/02-companies.exs`

alias CaseManager.Organizations.Company
alias CaseManager.Incidents.Case
alias CaseManager.Incidents.Alert
alias CaseManager.Incidents.Comment

require Ash.Query

# Check if we're in cleanup-only mode
clean_only = System.get_env("SEED_CLEAN_ONLY") == "true"

IO.puts("Cleaning existing comments, cases, alerts, and companies...")

# Clean up all dependencies before creating companies
# First delete all comments (which might be linked to cases or alerts)
Comment
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Then delete all cases (which reference companies)
Case
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Then delete all alerts (which reference companies)
Alert
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Now it's safe to delete existing companies
Company
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

# Exit early if we're only cleaning
if clean_only do
  IO.puts("✅ Cleanup completed. Exiting without creating new data.")
  System.halt(0)
end

# Define company data
# Note: Companies don't have any SOC association at creation time
# SOC relationships can be set up separately if needed
companies = [
  %{
    name: "Acme Corporation"
  },
  %{
    name: "TechNova Systems"
  },
  %{
    name: "GlobalBank Financial"
  },
  %{
    name: "Quantum Healthcare"
  },
  %{
    name: "EcoSolutions Inc."
  },
  %{
    name: "NexGen Retail"
  },
  %{
    name: "DataStream Analytics"
  },
  %{
    name: "OceanCarriers Logistics"
  }
]

# Create companies in database
IO.puts("Creating #{length(companies)} companies...")
Ash.bulk_create!(companies, Company, :create, return_errors?: true, authorize?: false)
IO.puts("✅ Companies created successfully")
