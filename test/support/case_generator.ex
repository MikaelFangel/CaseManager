defmodule CaseManagerWeb.CaseGenerator do
  @moduledoc """
  Generator to generate all a case without a team and alerts. This generator helps
  by providing all the needed data for a valid case.
  """
  use ExUnitProperties

  @doc """
  List of valid priorities. This is list is static and not to be used as generator.
  """
  def valid_priorities, do: ["Info", "Low", "Medium", "High", "Critical"]

  @doc """
  Generator for valid priorities for a case
  """
  def priority, do: StreamData.member_of(valid_priorities())

  @doc """
  List of valid statusses. The list should no be used diretly as a genrator
  becuase it's a static list.
  """
  def valid_statusses, do: ["In Progress", "Pending", "Closed", "Benign"]

  @doc """
  Generator valid statusses that adhere to the contraints of the database.
  """
  def status, do: StreamData.member_of(valid_statusses())

  @doc """
  Genarter valid and only valid case attributes. The attributes follow the database 
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
