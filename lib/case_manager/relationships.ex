defmodule CaseManager.Relationships do
  @moduledoc """
  Domain that represents cases and their related resources.
  """
  use Ash.Domain
  alias CaseManager.Relationships.CaseAlert

  resources do
    resource CaseAlert
  end
end
