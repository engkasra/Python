################################Find User#####################################

# scope = Id of Group (AMS AMS Developers)
# Returns UriAMS (ATSGroupMembersInfo)
# ATS Group Id (AMS AMS Developers) 1b6e8dea-b8d6-4fdc-ae67-4546fed82a92
$UriATS ="https://stageazure.asax.ir/tfs/AsaProjects/_api/_identity/ReadGroupMembers?__v=5&scope=1b6e8dea-b8d6-4fdc-ae67-4546fed82a92&readMembers=true"
$UriAMS = "https://stageazure.asax.ir/tfs/AsaProjects/_api/_identity/ReadGroupMembers?__v=5&scope=9f842053-c997-4c82-878b-58131a92b0b2&readMembers=true"
$UriAPI = "https://stageazure.asax.ir/tfs/AsaProjects/_api/_identity/ReadGroupMembers?__v=5&scope=643e3640-47ad-4475-b41d-d55c2b771224&readMembers=true"
$UriBI = "https://stageazure.asax.ir/tfs/AsaProjects/_api/_identity/ReadGroupMembers?__v=5&scope=71c2007d-5f17-40b4-a129-8a11cb5e8c0c&readMembers=true"
$UriMIC = "https://stageazure.asax.ir/tfs/AsaProjects/_api/_identity/ReadGroupMembers?__v=5&scope=a6d00819-f012-4c9e-a656-68c94340ceeb&readMembers=true"


$token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "asax\k.abdollahi","xwshx6p45byrkdruzayiquvp7bzttkunirxzj5tx2ih4yocxlfja")))
$headers = @{Authorization="Basic$token"}


# Gets Members info of each Group
$responseATS = Invoke-RestMethod -Method Get -ContentType "application/json" -Headers $headers -Uri $UriATS
$responseAMS = Invoke-RestMethod -Method Get -ContentType "application/json" -Headers $headers -Uri $UriAMS
$responseAPI = Invoke-RestMethod -Method Get -ContentType "application/json" -Headers $headers -Uri $UriAPI
$responseBI = Invoke-RestMethod -Method Get -ContentType "application/json" -Headers $headers -Uri $UriBI
$responseMIC = Invoke-RestMethod -Method Get -ContentType "application/json" -Headers $headers -Uri $UriMIC

##Get from predefined variable in pipeline
$UserName = "XXX"

# Fill array of name of  each team's member 
$OPSATSList = New-Object -TypeName PSObject -Property @{
    Name = "ATS"
    Member = @()
}
foreach ($identity in $responseATS.identities) {
    $OPSATSList.Member += $identity.DisplayName
 
}


$OPSAMSList = New-Object -TypeName PSObject -Property @{
    Name = "AMS"
    Member = @()
}
foreach ($identity in $responseAMS.identities) {
    $OPSAMSList.Member += $identity.DisplayName
 
}



$OPSAPIList = New-Object -TypeName PSObject -Property @{
    Name = "API"
    Member = @()
}
foreach ($identity in $responseAPI.identities) {
    $OPSAPIList.Member += $identity.DisplayName
 
}


$OPSBIList = New-Object -TypeName PSObject -Property @{
    Name = "BI"
    Member = @()
}


foreach ($identity in $responseBI.identities) {
    $OPSBIList.Member += $identity.DisplayName
 
}



$OPSMICList = New-Object -TypeName PSObject -Property @{
    Name = "MIC"
    Member = @()
}
foreach ($identity in $responseMIC.identities) {
    $OPSMICList.Member += $identity.DisplayName
  
}


# Find that the user is in which group
function Find-Username ($OPSTeam)
{

    foreach ($item in $OPSTeam.Member) {
        
        if ($UserName -eq $item) {
                $global:GroupName = $OPSTeam.Name
                Write-Output "Team Name is: $global:GroupName"
                Write-Output "Username is: $UserName"                         
                return $true
            }
        }

    return $false
}

Find-Username $OPSATSList 
Find-Username $OPSAMSList
Find-Username $OPSAPIList 
Find-Username $OPSBIList 
Find-Username $OPSMICList



######################Find TeamProject#################################

#Give information about deploymnet group and its deployment pool
$deploymentGroupName = "YYY"
$Uri = "https://stageazure.asax.ir/tfs/AsaProjects/AssetManagement/_apis/distributedtask/deploymentgroups?api-version=6.0-preview.1&deploymentGroupName=$($deploymentGroupName)"

$token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "asax\s.memarian","xwshx6p45byrkdruzayiquvp7bzttkunirxzj5tx2ih4yocxlfja")))
$headers = @{Authorization="Basic$token"}
$response = Invoke-RestMethod -Method Get -ContentType "application/json" -Headers $headers -Uri $Uri

#Find name of the dep pool of the dep group
$poolName = $null
foreach ($deploymentGroup in $response.value) {
     if ($deploymentGroup.name -eq $deploymentGroupName) {
        
         $poolName = $deploymentGroup.pool.name
         break
         
    }
}


#Find Team Project name from dp pool name
$poolNameReal = $poolName

$TeamProject = ($poolNameReal -split "-")[0] 
#Write-Host "Team Project name is: $TeamProject"

# Programs team project in static array 
$ATSTeam = New-Object -TypeName PSObject -Property @{
    Name = "ATS"
    Member = @("CCMS", "Club", "Tse", "AsaTotalSolution", "TinyProjects", "AtsImeFut", "Infrastructure", "HtmlFramework")
}

$AMSTeam = New-Object -TypeName PSObject -Property @{
    Name = "AMS"
    Member = @("AssetManagement", "OrderManagement", "AlgorithmTrading", "ExchangeGateway", "HtmlFramework", "Infrastructure", "Realtime")
}

$CDPTeam = New-Object -TypeName PSObject -Property @{
    Name = "CDP"
    Member = @("CustomerDevelopment", "Financial")
}

$BITeam = New-Object -TypeName PSObject -Property @{
    Name = "BI"
    Member = @("BrokerServices", "BrokerBI", "MarketDataProvider", "BankServices", "Sarand", "Ghasedak")
}

$MICTeam = New-Object -TypeName PSObject -Property @{
    Name = "MIC"
    Member = @("AgahServiceDesk", "Hamfekran", "Hamsabad", "MIC_Robin", "HumanResourceServices")
}

$APITeam = New-Object -TypeName PSObject -Property @{
    Name = "API"
    Member = @("ApiManager")
}

#Find name of the team project and team
function Has-Permission-on ($Thisteam, $testcase)
{

      foreach ($item in $Thisteam.Member) {
        if ($testcase -eq $item) {
                $global:teamName = $Thisteam.Name
                Write-Output "Teamproject is: $testcase"
                Write-Host "Team Name is: $global:teamName"

                return $true
                
           }
        }

    return $false
}




Has-Permission-on $ATSTeam $TeamProject 
Has-Permission-on $AMSTeam $TeamProject 
Has-Permission-on $CDPTeam $TeamProject 
Has-Permission-on $BITeam $TeamProject 
Has-Permission-on $MICTeam $TeamProject 
Has-Permission-on $APITeam $TeamProject 



###########Permission to Deployment Pool##########


Write-Host "--------------------------------"


#Write-Output $global:teamName
#Write-Output $global:GroupName

# Compare that if teamname and groupname is equal, set permission
if ($global:teamName -eq $global:GroupName){
 
 Write-Output "Contineu"
 
 #$Uri = "https://stageazure.asax.ir/tfs/AsaProjects/AssetManagement/_apis/distributedtask/deploymentgroups?api-version=6.0-preview.1&deploymentGroupName=YYY"

 #$token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "asax\s.memarian","xwshx6p45byrkdruzayiquvp7bzttkunirxzj5tx2ih4yocxlfja")))
 #$headers = @{Authorization="Basic$token"}
 #$response = Invoke-RestMethod -Method Get -ContentType "application/json" -Headers $headers -Uri $Uri

#Find poolId from the response that return info about dep group
$poolId = $null
foreach ($deploymentGroup in $response.value) {
     if ($deploymentGroup.name -eq $deploymentGroupName) {
        
         $poolId = $deploymentGroup.pool.id
         #return $deploymentGroup.pool.id
         break
        
    }
}

Write-Output $poolId

Write-Output "get deployment group ID"

#Find groupId (id of each team project (like AssetManagement)) from the response that return info about dep group
$groupId = $null
foreach ($deploymentGroup in $response.value) {
     if ($deploymentGroup.name -eq $deploymentGroupName) {
        
         $groupId = $deploymentGroup.project.id
         #return $deploymentGroup.pool.id
         break
        
    }
}

Write-Output $groupId

Write-Output "----------------------------------------------------------------------"

#Find poolName from the response that return info about dep group
$poolName = $null
foreach ($deploymentGroup in $response.value) {
     if ($deploymentGroup.name -eq $deploymentGroupName) {
        
         $poolName = $deploymentGroup.pool.name
         #return $deploymentGroup.pool.id
         break
        
    }
}
Write-Output $poolName

Write-Output "---------------------------------------------------------------------"

#Find TeamId of the team that user choose from pipeline
$MainTeamName = "ZZZ"

##Id of Ops teams
 $TeamId = switch ($MainTeamName) {
    'ATS' { '1b6e8dea-b8d6-4fdc-ae67-4546fed82a92' }
    'AMS' { '9f842053-c997-4c82-878b-58131a92b0b2' }
    'API' { '643e3640-47ad-4475-b41d-d55c2b771224' }
    'BI' { '71c2007d-5f17-40b4-a129-8a11cb5e8c0c' }
    'MIC' { 'dfcf1a08-6e2f-4836-ae36-a0e7299b8af6' }
    default { throw "Invalid TeamName parameter value: $MainTeamName" }
}


#Get info about memebers and her/his permission in specific Pool
$Uripool ="https://stageazure.asax.ir/tfs/AsaProjects/_apis/securityroles/scopes/distributedtask.deploymentpoolrole/roleassignments/resources/$($poolId)?api-version=6.0-preview.1"

$token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "asax\s.memarian","xwshx6p45byrkdruzayiquvp7bzttkunirxzj5tx2ih4yocxlfja")))
$headers = @{Authorization="Basic$token"}



 ####userId: accept id of user and group. Group Id is tfid in section of 

 $body = @"
 [
    {
        `"roleName`": `"User`",
        `"userId`": `"$($TeamId)`"
    }
 ]
"@  


 Invoke-RestMethod -Method Put -ContentType "application/json" -Headers $headers -Uri $Uripool -Body $body 


} else {
  
  Write-Output "You do not have permission"

}

Write-Output "--------------------===------"

###################Permission to Deployment Group#########################

#Get info about dep group and dep pool of each team project
$Uridep ="https://stageazure.asax.ir/tfs/AsaProjects/_apis/securityroles/scopes/distributedtask.machinegrouprole/roleassignments/resources/$($groupId)?api-version=7.0-preview.1"

$token = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f "asax\s.memarian","xwshx6p45byrkdruzayiquvp7bzttkunirxzj5tx2ih4yocxlfja")))
$headers = @{Authorization="Basic$token"}

 ####userId: accept id of user and group. Group Id is tfid in section of 

 $body = @"
 [
    {
        `"roleName`": `"User`",
        `"userId`": `"$($TeamId)`"
    }
 ]
"@  


 Invoke-RestMethod -Method Put -ContentType "application/json" -Headers $headers -Uri $Uridep -Body $body 

