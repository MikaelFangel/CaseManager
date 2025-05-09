# Seeds for User-Company relationships
#
# This seed file creates connections between users and companies
# (preserves all case and alert comments)
# Run with: `mix run priv/repo/seeds/09-user-company-relations.exs`

alias CaseManager.Accounts.User
alias CaseManager.Organizations.Company
alias CaseManager.Organizations.CompanyUser

require Ash.Query

IO.puts("Creating user-company relationships...")

# Clean up existing user-company relationships before creating new ones
# (This only affects CompanyUser records and preserves all comments)
IO.puts("Cleaning existing user-company relationships (preserving all comments)...")
existing_relations = Ash.read!(CompanyUser)
if length(existing_relations) > 0 do
  # Verify we're only dealing with CompanyUser records to ensure we don't affect comments
  if Enum.all?(existing_relations, fn rel -> is_struct(rel, CompanyUser) end) do
    Ash.bulk_destroy!(existing_relations, :delete, %{}, authorize?: false)
  else
    IO.puts("⚠️ Found non-CompanyUser records - skipping cleanup for safety")
  end
end

# Get all users and companies from the database
all_users = Ash.read!(User)
all_companies = Ash.read!(Company)

IO.puts("Found #{length(all_users)} users and #{length(all_companies)} companies")

# Create user-company relationships
user_company_relationships =
  Enum.flat_map(all_users, fn user ->
    # Determine how many companies this user will be part of (1-3)
    company_count = min(Enum.random(1..3), length(all_companies))
    
    # Assign random companies to this user
    companies_for_user = Enum.take_random(all_companies, company_count)
    
    # Create company-user relationships for this user
    Enum.map(companies_for_user, fn company ->
      %{
        user_id: user.id,
        company_id: company.id
      }
    end)
  end)

# Make sure all companies have at least one user assigned
ensured_relationships =
  Enum.reduce(all_companies, user_company_relationships, fn company, acc ->
    # Check if this company has at least one user assigned
    has_users = Enum.any?(acc, fn rel -> rel.company_id == company.id end)
    
    # If no users assigned, assign a random user
    if not has_users and length(all_users) > 0 do
      random_user = Enum.random(all_users)
      [%{user_id: random_user.id, company_id: company.id} | acc]
    else
      acc
    end
  end)

# Remove any duplicates
unique_relations = Enum.uniq_by(ensured_relationships, fn rel -> {rel.user_id, rel.company_id} end)

IO.puts("Creating #{length(unique_relations)} user-company relationships...")

if length(unique_relations) > 0 do
  # Use Ash.bulk_create with the first parameter as the list of relations
  Ash.bulk_create!(unique_relations, CompanyUser, :create, authorize?: false)
  IO.puts("✅ User-company relationships created successfully")
else
  IO.puts("⚠️ No user-company relationships to create")
end