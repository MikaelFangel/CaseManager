defmodule CaseManager.Teams.UserTest do
  use CaseManager.DataCase, async: true
  use ExUnitProperties

  describe "CaseManager.Teams.get_user_by_id" do
    test "user can only themselves" do
      user = generate(user(role: :analyst))
      other = generate(user())

      assert CaseManager.Teams.can_get_user_by_id?(user, user.id, data: user)
      refute CaseManager.Teams.can_get_user_by_id?(user, other.id, data: other)
    end

    test "admin can get another user by id" do
      admin = generate(user(role: :admin))
      [user1, user2] = generate_many(user(), 2)

      assert CaseManager.Teams.can_get_user_by_id?(admin, user1.id, data: user1)
      assert CaseManager.Teams.can_get_user_by_id?(admin, user2.id, data: user2)
    end
  end

  describe "CaseManager.Teams.User" do
    test "user can sign in" do
      user = generate(user())

      assert CaseManager.Teams.User
             |> Ash.Query.for_read(:sign_in_with_password, %{email: user.email, password: "password"})
             |> Ash.read!()
    end
  end
end
