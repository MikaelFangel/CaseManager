# Seeds for User-SOC relationships
#
# This seed file creates connections between users and SOCs
# (preserves all case and alert comments)
# Run with: `mix run priv/repo/seeds/08-user-soc-relations.exs`

alias CaseManager.Accounts.User
alias CaseManager.Organizations.SOC
alias CaseManager.Organizations.SOCUser

require Ash.Query

IO.puts("Creating user-SOC relationships...")

# Clean up existing user-SOC relationships before creating new ones
# (This only affects SOCUser records and preserves all comments)
IO.puts("Cleaning existing user-SOC relationships (preserving all comments)...")
existing_relations = Ash.read!(SOCUser)
if length(existing_relations) > 0 do
  # Verify we're only dealing with SOCUser records to ensure we don't affect comments
  if Enum.all?(existing_relations, fn rel -> is_struct(rel, SOCUser) end) do
    Ash.bulk_destroy!(existing_relations, :delete, %{}, authorize?: false)
  else
    IO.puts("⚠️ Found non-SOCUser records - skipping cleanup for safety")
  end
end

# Get all users and SOCs from the database
all_users = Ash.read!(User)
all_socs = Ash.read!(SOC)

IO.puts("Found #{length(all_users)} users and #{length(all_socs)} SOCs")

# Create user-soc relationships
user_soc_relationships =
  Enum.flat_map(all_users, fn user ->
    # Determine how many SOCs this user will be part of (1-3)
    soc_count = min(Enum.random(1..3), length(all_socs))
    
    # Assign random SOCs to this user
    socs_for_user = Enum.take_random(all_socs, soc_count)
    
    # Create SOC-user relationships for this user
    Enum.map(socs_for_user, fn soc ->
      %{
        user_id: user.id,
        soc_id: soc.id
      }
    end)
  end)

# Make sure all SOCs have at least one user assigned
ensured_relationships =
  Enum.reduce(all_socs, user_soc_relationships, fn soc, acc ->
    # Check if this SOC has at least one user assigned
    has_users = Enum.any?(acc, fn rel -> rel.soc_id == soc.id end)
    
    # If no users assigned, assign a random user
    if not has_users and length(all_users) > 0 do
      random_user = Enum.random(all_users)
      [%{user_id: random_user.id, soc_id: soc.id} | acc]
    else
      acc
    end
  end)

# Remove any duplicates
unique_relations = Enum.uniq_by(ensured_relationships, fn rel -> {rel.user_id, rel.soc_id} end)

IO.puts("Creating #{length(unique_relations)} user-SOC relationships...")

if length(unique_relations) > 0 do
  # Use Ash.bulk_create with the first parameter as the list of relations
  Ash.bulk_create!(unique_relations, SOCUser, :create, authorize?: false)
  IO.puts("✅ User-SOC relationships created successfully")
else
  IO.puts("⚠️ No user-SOC relationships to create")
end