# Microsoft Entra ID IAM Audit Notes

**Organization:** THL (Simulated)  
**Environment:** Microsoft Entra ID Lab Tenant  
**Assessment Type:** Identity Configuration and Access Review  
**Status:** In Progress

## 1. Environment Overview

| Component | Details |
|---|---|
| Identity Platform | Microsoft Entra ID |
| User Accounts | 7 |
| Security & Microsoft 365 Groups | 9 total groups |
| Applications | 4 shown in tenant overview |
| PowerShell | 7.6.9 |
| Microsoft Graph SDK | 2.41.2 |
| Authentication | Delegated OAuth 2.0 |

**Evidence:** 
- [Tenant Information](../Images/tenant-info.png)
- [Microsoft Graph Modules](../Images/graph-modules.png)
- [Microsoft Graph Authentication](../Images/graph-auth.png)

## 2. User Inventory

**Objective:** Establish an identity inventory to identify account configurations requiring security review.

**Methodology:** Queried Microsoft Entra ID using `Get-MgUser` and collected display names, UPNs, account status, user classification, and creation timestamps.

**Results:**

| Metric | Count |
|---|---:|
| Total Accounts | 7 |
| Enabled Accounts | 6 |
| Disabled Accounts | 1 |
| Member Accounts | 7 |
| Guest Accounts | 0 |

**Observation:** All seven accounts were classified as Members. One account was identified as disabled.

**Evidence:** [User Inventory](../Images/user-inventory.png)

## 3. Account Status Analysis

**Objective:** Identify disabled identities for further access lifecycle review.

**Methodology:** Filtered retrieved user objects using PowerShell `Where-Object` against the `AccountEnabled` property.

**Results:**
- Six accounts are enabled.
- One account, Victor Wemby (test identity), is disabled.

**Security Assessment:** One disabled identity was identified for further access review. Subsequent testing confirmed retained group memberships and a group-based enterprise application assignment, documented in Section 4.

**Evidence:** [Account Status Analysis](../Images/account-status.png)

## 4. Disabled Account Membership Review

**Objective:** Identify direct group memberships retained by a disabled account.

**Methodology:** Queried the disabled identity using `Get-MgUserMemberOfAsGroup` to enumerate direct group memberships.

**Results:**
- Disabled identity: Victor Wemby
- Direct group memberships: 2
- Groups: Contractors, All Company (Dynamic)

**Security Assessment:** The disabled identity retains membership in two security groups. Subsequent testing confirmed that Contractors grants a group-based enterprise application assignment, while All Company (Dynamic) uses an all-users membership rule. The business justification for retaining these assignments remains unverified.

**Evidence:** [Disabled Account Memberships](../Images/disabled-account-memberships.png)

### Contractors Group Verification

**Methodology:** Inspected the Contractors security group in the Microsoft Entra admin center to validate membership and group configuration.

**Results:**
- Group type: Security
- Membership type: Assigned
- Source: Cloud
- Direct members: 1 (Victor Wemby, disabled)
- Group owners: 0
- Nested group memberships: 0

**Security Assessment:** Confirmed that the disabled identity retains membership in an assigned security group. Subsequent testing identified an enterprise application assignment associated with this group. Offboarding requirements remain unverified.

**Evidence:** 
- [Contractors Group Overview](../Images/contractors-group-overview.png)
- [Contractors Group Members](../Images/contractors-group-members.png)

### Enterprise Application Assignment Review

**Objective:** Determine whether the disabled account's retained group membership is associated with enterprise application access.

**Methodology:** Reviewed enterprise application assignments in the Microsoft Entra admin center and compared them with the disabled account's group memberships.

**Results:**
- Application: THL Contractor Portal Demo
- Assigned security group: Contractors
- Disabled identity: Victor Wemby
- Authorization path: Victor Wemby → Contractors → THL Contractor Portal Demo

**Security Assessment:** Confirmed that a disabled identity retains group-based application assignment. Current access is not established because the account is disabled. Reactivation may restore authorization without an additional group membership review.

**Evidence:** [Contractor Portal Application Assignment](../Images/contractors-app-assignment.png)

### Dynamic Group Membership Rule Review

**Objective:** Determine why a disabled identity remains in the All Company (Dynamic) security group.

**Methodology:** Retrieved the group's membership rule and processing state using Microsoft Graph PowerShell (`Get-MgGroup`).

**Results:**
- Group: All Company (Dynamic)
- Membership type: Dynamic User
- Membership rule: `user.objectId -ne null`
- Rule processing state: On
- Disabled account included: Victor Wemby

**Security Assessment:** The rule includes all users with an object ID, regardless of account status or user classification. Victor's membership is consistent with the configured rule. The security impact depends on the group's resource assignments and intended access requirements.

**Evidence:** [Dynamic Group Membership Rule](../Images/dynamic-group-rule.png)

### Dynamic Group Application Assignment Review

**Methodology:** Reviewed the Applications section of the All Company (Dynamic) security group in Microsoft Entra ID.

**Results:**
- Enterprise application assignments found: 0
- Membership rule: `user.objectId -ne null`
- Disabled account included: Victor Wemby

**Security Assessment:** No enterprise application assignments were identified for the dynamic group. Its membership rule includes disabled identities, but no application access impact was established during this review. Permissions to other resource types have not been assessed.

## 5. Preliminary Findings and Follow-Up

| ID | Observation | Status |
|---|---|---|
| OBS-001 | Disabled account retains group-based enterprise application assignment | Pending access impact and lifecycle review |

No confirmed security vulnerabilities have been established.

## 6. Assessment Limitations

- Assessment performed against a simulated tenant containing seven user accounts.
- Business authorization requirements and offboarding history have not been verified.
- Group membership does not independently prove effective application access.
- Transitive group memberships and tenant-wide privileged role assignments have not been comprehensively assessed.
- Identity inventory and access investigations were performed using read-only queries.

## 7. Group Inventory

**Objective:** Inventory Microsoft Entra ID groups and identify their membership configurations.

**Methodology:** Queried group objects using Microsoft Graph PowerShell (`Get-MgGroup`) and reviewed group types, security enablement, and mail enablement.

**Results:**
- Total groups: 9
- Assigned security groups: 5
- Dynamic security groups: 1
- Microsoft 365 groups: 3

**Security Assessment:** Group inventory completed successfully. No security misconfigurations were confirmed from group attributes alone. Further membership and access assignment analysis is required.

**Evidence:** [Group Inventory](../Images/group-inventory.png)

## 8. Group Membership Inventory

**Objective:** Enumerate direct user memberships across Microsoft Entra ID groups.

**Methodology:** Automated direct user membership enumeration across nine groups using `Get-MgGroupMemberAsUser` and a PowerShell `foreach` loop. Exported the results to CSV for further analysis.

**Results:**
- Groups reviewed: 9
- Direct group-user membership records: 20
- Groups with direct user members: 7
- Largest group: All Company (Dynamic), 7 users
- Groups with no direct user members: Sales, Viva Engage group
- Disabled identity Victor Wemby remains a member of Contractors and All Company (Dynamic).

**Security Assessment:** Group memberships were successfully inventoried. No new confirmed security vulnerabilities were identified. The retained Contractors application assignment remains under investigation as OBS-001.

**Script:** [Get-GroupMemberships.ps1](../Scripts/Get-GroupMemberships.ps1)