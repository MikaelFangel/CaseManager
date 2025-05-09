# Seeds for Case-Alert relationships
#
# This seed file creates connections between cases and alerts
# Run with: `mix run priv/repo/seeds/06-case-alert-relations.exs`

alias CaseManager.Incidents.Case
alias CaseManager.Incidents.Alert
alias CaseManager.Incidents.CaseAlert

require Ash.Query

IO.puts("Creating case-alert relationships...")

# Clean up existing case-alert relationships before creating new ones
IO.puts("Cleaning existing case-alert relationships...")
existing_relations = Ash.read!(CaseAlert)
if length(existing_relations) > 0 do
  Ash.bulk_destroy!(existing_relations, :destroy, %{}, authorize?: false)
end

# Get all cases and alerts from the database
all_cases = Ash.read!(Case)
all_alerts = Ash.read!(Alert)

IO.puts("Found #{length(all_cases)} cases and #{length(all_alerts)} alerts")

# Create a list of relations
relations = 
  all_cases
  |> Enum.flat_map(fn case_record -> 
      # Assign 2 random alerts to each case
      all_alerts
      |> Enum.take_random(min(2, length(all_alerts)))
      |> Enum.map(fn alert -> 
          %{case_id: case_record.id, alert_id: alert.id}
        end)
    end)

IO.puts("Creating #{length(relations)} case-alert relationships...")

if length(relations) > 0 do
  Ash.bulk_create!(relations, CaseAlert, :create, authorize?: false)
  IO.puts("✅ Case-alert relationships created successfully")
else
  IO.puts("⚠️ No case-alert relationships to create")
end