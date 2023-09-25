#This is test
#version 0.1
<#
.SYNOPSIS
    Add/Remove Member to/from AzureDevops Group
.DESCRIPTION
    usage: sample 1: Adding "asax\o.shariati" to "Ats Admins" group
    -action "add" -member "asax\o.shariati" -groupName "Ats Admins" -pat "abcdefghijklmnopqrstuvwxyz"
    
    usage: sample 2: Removing "asax\o.shariati" from "Ats Admins" group
    -action "remove" -member "asax\o.shariati" -groupName "Ats Admins" -pat "abcdefghijklmnopqrstuvwxyz"
    
    azure devops api references:
    https://learn.microsoft.com/en-us/rest/api/azure/devops/?view=azure-devops-rest-7.1&viewFallbackFrom=azure-devops-rest-6.0

.PARAMETER action
    Could be "add" or "remove"
.PARAMETER username
    member username such as o.shariati
.PARAMETER groupName
    The AzureDevOps group name to add/remove member to/from that member
#>

[CmdletBinding()]
param( 
    #[Alias("a")]
    [Parameter(Mandatory=$true)]
    #[ValidateSet('add','remove')]
    [string] $action = "",
    
    #[Alias("u")]
    [Parameter(Mandatory=$true)]
    [string] $username = "",
    
    #[Alias("g")]
    [Parameter(Mandatory=$true)]
    [string] $groupName = "" ,
    
    #[Alias("u_token")]
    [Parameter(Mandatory=$true)]
    [string] $user_token = "" ,

    #[Alias("pat")]
    [Parameter(Mandatory=$true)]
    [string] $token = "" #,
    
    ##[Alias("pc")]
    #[Parameter(Mandatory=$false)]
    #[string] $projectCollection = "", # "AsaProjects", ...
    

)

Write-Host "Starting ..."
# Step 0: Set default values
$access_token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "asax\$user_token","$token")))
$headers = @{Authorization="Basic$access_token"}
$response = Invoke-RestMethod -Method Get -Uri $baseUrl -Headers $headers

# Step 1: Input validation functions

function ValidateInputs()
{
    $allowed_actions = "add","remove"
    if($allowed_actions -contains $action.ToLower())
    {
        return $true;
    }
    else
    {
        # todo: Write log
        Write-Host "Error: input for action parameters is invalid. Allowed inputes are 'add' and 'remove'"
        Write-Host "you enters action: '$action' "
        return $false;
    }
    if($username.ToLower() -eq "")
    {
        # todo: Write error
        Write-Host "Error: please enter your Asax domain user"
        return $false;
    }
    else
    {
        return $true;
    }
    if($groupName.ToLower() -eq "")
    {
        # todo: Write error
        Write-Host "Error: please enter valid data which group in Azure Devops do you want to change"
        return $false;
    }
    if($token -eq "")
    {
        # todo: Write error
        Write-Host "Error: the access token is not valid or has expired"
        return $false;
    }

    return $true;
}

# Step 2: Function definitions
# todo: such as
#    function FindMemberIdByUserName
#    function FindGroupIdByGroupName
#    function AddMemberToGroup
#    function RemoveMemberFromGroup

function FindMemberIdByUserName($uame){

    $baseUrl = "https://azure.asax.ir/tfs/AsaProjects/_apis/identities?searchFilter=General&filterValue=$uname&queryMembership=None&api-version=7.0"
    $memberId = $response.value
    return $memberId.id
    
    # if($response.value.Count -eq 0)
    # {
    # }
    # elseif ($response.value.Count -gt 1)
    # {
    #     # error 
    # }
    # else {
    #     return $memberId.id
    # }

    # api call to find memberId by user
    # https://learn.microsoft.com/en-us/rest/api/azure/devops/ims/identities/read-identities?view=azure-devops-rest-6.0&tabs=HTTP#identity    
    # if not found raise error
}
$tc = FindGroupIdByGroupName($username)
Write-Host $tc
# # TEST OUTPUT-MemberFunction
# # $tc = FindMemberIdByUserName($username)
# # Write-Host $tc

# function FindProjectIdByName($projectName)
# {
#     #https://azure.asax.ir/tfs/AsaProjects/_apis/projects?api-version=7.0 ----> to get all projects id
#     return "80ed6180-f40c-4490-b7fd-15f35d4c6c76"; # todo: this is hardcoded projectId of "General" team project and shold change later
# }

# function GetSecurityGroupListByProjectId($projectName)
# {
#     $projectId = FindProjectIdByName($projectName);
#     # $baseUrl/$projectId/_api/_identity/ReadScopedApplicationGroupsJson?__v=5
    
#     # example: https://azure.asax.ir/tfs/AsaProjects/80ed6180-f40c-4490-b7fd-15f35d4c6c76/_api/_identity/ReadScopedApplicationGroupsJson?__v=5

#     # return a list of security group information included projectName, projectId, IsProjectLevel, etc
# }

# function FindSecurityGroupIdByName($groupName) # $projectId
# {
#     # GetSecurityGroupListByProjectId

#     # return security group id
# }

# function FindGroupIdByGroupName($gname, $projectId) {
#     # $baseUrl = ""
#     $groupId = $response.value
#     return $groupId.id
# }

# function AddMemberToGroup($username, $groupName, $pat){
    
#     $memberId = FindMemberIdByUserName($username, $pat);
    
#     $groupId = FindGroupIdByGroupName($groupname, $pat);

#     # api call to add member to group
#     # https://learn.microsoft.com/en-us/rest/api/azure/devops/memberentitlementmanagement/members/add?view=azure-devops-rest-6.0

#     # if(api call is success)
#     #{ message: user ---- added successfully to group ---- }
#     # else { message Error}

#     return $true;
# }

# function RemoveMemberFromGroup($username, $groupName, $pat){
    
#     $memberId = FindMemberIdByUserName($username, $groupName, $pat);

#     return $memberId;
# }

# # Step 3: Last Step - Actions
# if(ValidateInputs -eq $true) {
#     # Do Action
#     if($action.ToLower() -eq "add")
#     {
#         # todo: Call AddMemberToGroup($username, $groupname)
#     }
#     elseif($action.ToLower() -eq "remove")
#     {
#         # todo: Call RemoveMemberFromGroup($username, $group)
#         # https://learn.microsoft.com/en-us/rest/api/azure/devops/memberentitlementmanagement/members/remove-member-from-group?view=azure-devops-rest-6.0
#     }
# }
# else {
#     # todo: Write Error
#     # todo: Exit
# }

# Write-Host "Finish ..."
