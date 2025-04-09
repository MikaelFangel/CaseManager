alias CaseManager.Accounts.User

require Ash.Query

User
|> Ash.read!()
|> Ash.bulk_destroy!(:delete, %{}, authorize?: false)

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
  }
]

# Create the users
Ash.bulk_create!(users_data, User, :register_with_password, authorize?: false, return_records?: true)
