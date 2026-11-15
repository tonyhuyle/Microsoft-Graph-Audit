# Microsoft Entra ID Group Membership Inventory
# Project: THL IAM Audit

$groups = Get-MgGroup -All

$membershipReport = foreach ($group in $groups) {
    $members = @(Get-MgGroupMemberAsUser -GroupId $group.Id -All)

    foreach ($member in $members) {
        [PSCustomObject]@{
            GroupName         = $group.DisplayName
            GroupId           = $group.Id
            MemberName        = $member.DisplayName
            UserPrincipalName = $member.UserPrincipalName
            MemberId          = $member.Id
        }
    }
}

$membershipReport | Export-Csv -Path "./group-members.csv" -NoTypeInformation -Encoding UTF8

Write-Host "Exported $($membershipReport.Count) group membership records."