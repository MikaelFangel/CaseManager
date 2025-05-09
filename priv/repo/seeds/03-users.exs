# Seeds for User accounts
#
# This seed file creates users that can log in to the system and interact with cases
# Run with: `mix run priv/repo/seeds/03-users.exs`
# For cleanup only: `SEED_CLEAN_ONLY=true mix run priv/repo/seeds/03-users.exs`

alias CaseManager.Accounts.User

require Ash.Query

# Check if we're in cleanup-only mode
clean_only = System.get_env("SEED_CLEAN_ONLY") == "true"

# Note: User resource doesn't have a :delete action defined
# If needed, individual users should be managed via the application
# We'll just print a message in cleanup mode

if clean_only do
  IO.puts("Note: Cannot bulk delete users. The User resource doesn't have a :delete action.")
  IO.puts("✅ Cleanup completed. Exiting without creating new data.")
  System.halt(0)
end

# Define user data with various roles and departments
users_data = [
  %{
    email: "admin@example.com",
    first_name: "Admin",
    last_name: "User",
    password: "password123",
    password_confirmation: "password123"
  },
  %{
    email: "john.smith@example.com",
    first_name: "John",
    last_name: "Smith",
    password: "password123",
    password_confirmation: "password123"
  },
  %{
    email: "jane.doe@example.com",
    first_name: "Jane",
    last_name: "Doe",
    password: "password123",
    password_confirmation: "password123"
  },
  %{
    email: "michael.johnson@example.com",
    first_name: "Michael",
    last_name: "Johnson",
    password: "password123",
    password_confirmation: "password123"
  },
  %{
    email: "emily.williams@example.com",
    first_name: "Emily",
    last_name: "Williams",
    password: "password123",
    password_confirmation: "password123"
  },
  %{
    email: "alex.rodriguez@example.com",
    first_name: "Alex",
    last_name: "Rodriguez",
    password: "password123",
    password_confirmation: "password123"
  },
  %{
    email: "sarah.chen@example.com",
    first_name: "Sarah",
    last_name: "Chen",
    password: "password123",
    password_confirmation: "password123"
  },
  %{
    email: "david.patel@example.com",
    first_name: "David",
    last_name: "Patel",
    password: "password123",
    password_confirmation: "password123"
  },
  %{
    email: "olivia.nguyen@example.com",
    first_name: "Olivia",
    last_name: "Nguyen",
    password: "password123",
    password_confirmation: "password123"
  }
]

# Get existing users to avoid duplicates
existing_users = Ash.read!(User)
existing_emails = Enum.map(existing_users, fn user -> 
  # Convert Ash.CiString to string for proper comparison
  to_string(user.email) 
end)

# Filter out users that already exist
new_users = Enum.filter(users_data, fn user_data -> 
  user_email = user_data.email
  !Enum.member?(existing_emails, user_email)
end)

if length(new_users) > 0 do
  # Create only the new users
  IO.puts("Creating #{length(new_users)} new users...")
  Ash.bulk_create!(new_users, User, :register_with_password, authorize?: false, return_records?: true)
  IO.puts("✅ Users created successfully")
else
  IO.puts("✅ No new users to create. All users already exist.")
end
