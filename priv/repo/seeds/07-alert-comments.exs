# Seeds for Alert Comments
#
# This seed file creates comments linked to alerts (preserving case comments)
# Run with: `mix run priv/repo/seeds/07-alert-comments.exs`

alias CaseManager.Incidents.Alert
alias CaseManager.Incidents.Comment
alias CaseManager.Accounts.User

require Ash.Query

IO.puts("Creating alert comment relationships...")

# Get all alerts and users from the database
all_alerts = Ash.read!(Alert)
all_users = Ash.read!(User)

IO.puts("Found #{length(all_alerts)} alerts and #{length(all_users)} users")

# Clean up existing alert comments before creating new ones (preserving case comments)
IO.puts("Cleaning existing alert comments (preserving case comments)...")
existing_alert_comments = 
  Comment
  |> Ash.Query.filter(not is_nil(alert_id))
  |> Ash.read!()

# Double-check that we're not accidentally deleting case comments
if length(existing_alert_comments) > 0 do
  # Safety check - make sure none of the comments have case_id set
  case_comments = Enum.filter(existing_alert_comments, fn comment -> not is_nil(comment.case_id) end)
  
  if length(case_comments) > 0 do
    IO.puts("⚠️ WARNING: Found #{length(case_comments)} comments linked to both cases and alerts")
    # Remove these from our list to ensure we don't delete case comments
    existing_alert_comments = Enum.filter(existing_alert_comments, fn comment -> is_nil(comment.case_id) end)
  end
  
  IO.puts("Deleting #{length(existing_alert_comments)} alert-only comments...")
  Ash.bulk_destroy!(existing_alert_comments, :delete, %{}, authorize?: false)
end

# Create specific comments for certain alert types
total_comments = 0

# Helper function to create a comment with basic error handling
create_comment = fn alert, body, visibility, user ->
  comment_attrs = %{
    body: body,
    visibility: visibility,
    alert_id: alert.id
  }
  
  try do
    Ash.create!(Comment, comment_attrs, actor: user, authorize?: false)
    true
  rescue
    e -> 
      IO.puts("Error creating comment: #{inspect(e)}")
      false
  end
end

# Add comments to suspicious login alerts
login_alerts = Enum.filter(all_alerts, fn a -> String.contains?(a.title, "Login") end)
Enum.each(login_alerts, fn alert ->
  random_user = Enum.random(all_users)
  
  # Add 2-3 comments per alert with different visibilities
  create_comment.(alert, "Investigating this suspicious login. Will check if the user was traveling.", :internal, random_user)
  create_comment.(alert, "Our team is investigating this login activity. Have you traveled recently?", :public, random_user)
  create_comment.(alert, "I've seen this pattern before - possible credential theft. Need to follow up.", :personal, random_user)
  
  total_comments = total_comments + 3
end)

# Add comments to malware alerts
malware_alerts = Enum.filter(all_alerts, fn a -> String.contains?(a.title, "Malware") end)
Enum.each(malware_alerts, fn alert ->
  random_user = Enum.random(all_users)
  
  create_comment.(alert, "Malware identified. Initiated containment protocol and isolated affected systems.", :internal, random_user)
  create_comment.(alert, "We've identified potentially malicious software on a device. Our team is responding.", :public, random_user)
  
  total_comments = total_comments + 2
end)

# Add comments to data exfiltration alerts
exfil_alerts = Enum.filter(all_alerts, fn a -> String.contains?(a.title, "Exfiltration") end)
Enum.each(exfil_alerts, fn alert ->
  random_user = Enum.random(all_users)
  
  create_comment.(alert, "Large data transfer detected. Checking packet captures to identify data types.", :internal, random_user)
  create_comment.(alert, "Unusual data transfer being investigated. No action needed from your team at this time.", :public, random_user)
  create_comment.(alert, "Private note: This looks similar to the patterns in case #2234 from last month.", :personal, random_user)
  
  total_comments = total_comments + 3
end)

# Add comments to privilege escalation alerts
priv_alerts = Enum.filter(all_alerts, fn a -> String.contains?(a.title, "Privilege") end)
Enum.each(priv_alerts, fn alert ->
  random_user = Enum.random(all_users)
  
  create_comment.(alert, "User gained admin rights outside normal approval process. Investigating intent.", :internal, random_user)
  create_comment.(alert, "Account privilege change detected. Verification in progress.", :public, random_user)
  
  total_comments = total_comments + 2
end)

# Add comments to phishing alerts
phishing_alerts = Enum.filter(all_alerts, fn a -> String.contains?(a.title, "Phishing") end)
Enum.each(phishing_alerts, fn alert ->
  random_user = Enum.random(all_users)
  
  create_comment.(alert, "Phishing campaign identified. 14 recipients, 3 clicked links, 1 entered credentials.", :internal, random_user)
  create_comment.(alert, "We've detected a phishing attempt targeting your organization. Security awareness reminder sent.", :public, random_user)
  create_comment.(alert, "Need to update our phishing simulation to match this technique - very sophisticated.", :personal, random_user)
  
  total_comments = total_comments + 3
end)

# Add comments to cloud storage alerts
cloud_alerts = Enum.filter(all_alerts, fn a -> String.contains?(a.title, "Cloud") end)
Enum.each(cloud_alerts, fn alert ->
  random_user = Enum.random(all_users)
  
  create_comment.(alert, "Sensitive bucket accessed from unusual location. Checking if this is legitimate travel.", :internal, random_user)
  create_comment.(alert, "Note to self: Add these bucket access patterns to our monitoring rules.", :personal, random_user)
  
  total_comments = total_comments + 2
end)

# Add at least one comment to every remaining alert
remaining_alerts = Enum.filter(all_alerts, fn alert ->
  not (String.contains?(alert.title, "Login") or 
       String.contains?(alert.title, "Malware") or
       String.contains?(alert.title, "Exfiltration") or 
       String.contains?(alert.title, "Privilege") or
       String.contains?(alert.title, "Phishing") or
       String.contains?(alert.title, "Cloud"))
end)

Enum.each(remaining_alerts, fn alert ->
  random_user = Enum.random(all_users)
  
  visibility = Enum.random([:internal, :public, :personal])
  body = case visibility do
    :internal -> "Internal investigation in progress for this alert."
    :public -> "We're looking into this alert. We'll update you with more information soon."
    :personal -> "Personal note: Need to check this alert against our knowledge base."
  end
  
  success = create_comment.(alert, body, visibility, random_user)
  
  if success do
    total_comments = total_comments + 1
  end
end)

IO.puts("✅ Created approximately #{total_comments} alert comments")