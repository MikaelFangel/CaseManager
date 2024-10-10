defmodule CaseManagerWeb.CaseGenerator do
  @moduledoc """
  Generator to generate all attributes for a case except for team_id and alerts. The team_id need to
  be a valid team_id in the database and the alerts linked also need to exist. This generator helps
  by providing all the needed data for a valid case.
  """
  use ExUnitProperties

  @doc """
  List of valid priorities. This is list is static and not to be used as generator.
  """
  def valid_priorities, do: [:info, :low, :medium, :high, :critical]

  @doc """
  Generator for valid priorities for a case
  """
  def priority, do: StreamData.member_of(valid_priorities())

  @doc """
  List of valid statuses. The list should no be used directly as a generator
  because it's a static list.
  """
  def valid_statusses, do: [:in_progress, :pending, :t_positive, :f_positive, :benign]

  @doc """
  Generator valid statuses that adhere to the constraints of the database.
  """
  def status, do: StreamData.member_of(valid_statusses())

  @doc """
  Generator for valid and only valid case attributes. The attributes follow the database 
  contraints and the other missing attributes such as team_id etc. should be manually
  inserted.
  """
  def case_attrs do
    gen all(
          title <- StreamData.string(:printable, min_length: 1),
          description <- StreamData.string(:utf8),
          status <- status(),
          priority <- priority(),
          escalated <- StreamData.boolean()
        ) do
      %{
        title: title,
        description: description,
        status: status,
        priority: priority,
        escalated: escalated
      }
    end
  end
end
