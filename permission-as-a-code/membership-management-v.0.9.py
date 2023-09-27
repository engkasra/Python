import requests
import base64
import json
from enum import Enum

#enum use for advance and optimize code, if we have many options in action variable
# class ActionList(Enum):
#     add = 1
#     delete = 2

# Step 1 _ Input Data Into The Variables ###

baseurl = "https://stage azure.asax.ir/tfs" or input ('Azure DevOps Url: ')
teamprojectcollection = "AsaProjects" or input ('Team Project Collection Name: ')
teamprojectname = input ('TeamProject: ')
action = input ('Action: ')
username = input ('Username: ')
groupname = input ('Groupname: ')
pat = input ('Token: ')


# Step 2 _ Set The Request Headers And Encode The Personal Access Token ###
headers = {
"Authorization": "Basic " + base64.b64encode(bytes(":" + pat, "ascii")).decode("ascii")
}

# Step 3 _ Check Valid Data In Variables ###

def ValidateInputes():
    allowed_action = "add", "remove"
    if action not in allowed_action:
        print ("Error: input for action parameters is invalid. Allowed inputes are 'add' and 'remove'")
        exit(1)
    if username =="":
        print("Error: please enter your Asax domain user")
        exit(2)
    if teamprojectname =="":
        print("Error: please enter valid team project name")
        exit(3)
    if groupname =="":
        print("Error: please enter valid group name in teamproject that you want to edit")
        exit(4)
    # if usertoken =="":
    #     print("Error: please enter creator of pat")
    #     exit(5)
    if pat =="":
        print("Error: token has expired or not valid")
        exit(6)

# Step 4 _ All Operation Functions ###

def FindTeamProjectIDbyName(teamproject_name: str) -> str:
    print ("Info: FindTeamProjectIDbyName")
    url= f"{baseurl}/{teamprojectcollection}/_apis/projects?api-version=7.0"
    response = requests.get(url, headers=headers)
    team_projects = response.json()["value"]
    for team_project in team_projects:
        if teamproject_name == team_project["name"]:
            return team_project["id"]
        
def GetSecurityGroupIDbyTeamID(team_id: str) -> str:
    print ("Info: GetSecurityGroupIDbyTeamID")
    #need team_id to add as variable = FindTeamProjectIDbyName()
    url = f"{baseurl}/{teamprojectcollection}/{team_id}/_api/_identity/ReadScopedApplicationGroupsJson?api-version=7.0"
    response = requests.get(url, headers=headers)
    groups_list = response.json()["identities"]
    for group_id in groups_list:
        if groupname == group_id["FriendlyDisplayName"]:
            return group_id["TeamFoundationId"]

def FindUserIDbyName(username: str) -> str:
    print ("Info: FindUserIDbyName")
    url = f"{baseurl}/{teamprojectcollection}/_apis/identities?searchFilter=General&filterValue={username}&queryMembership=None&api-version=7.0"
    response = requests.get(url, headers=headers)
    user_id = response.json()["value"][0]
    return user_id["id"]

def AddUserToGroup(group_id: str, user_id: str, team_id: str) -> bool:
    print ("Info: AddUserToGroup")
    url = f"{baseurl}/{teamprojectcollection}/{team_id}/_api/_identity/AddIdentities?__v=5" #Post
    payload = {"newUsersJson": [],
               "aadGroupsJson": [],
               "existingUsersJson": f'["{user_id}"]',
               "groupsToJoinJson": f'["{group_id}"]',
    }
    response = requests.post(url, json=payload, headers={**headers, "Content-Type": "application/json; charset=utf-8"})
    print(response.status_code)
    if response.status_code == 200:
        return True
    else:
        print(response)
        return False

def RemoveUserFromeGroup(group_id: str, user_id: str, team_id: str) -> bool:
    print ("Info: RemoveUserFromeGroup")
    #should check this api, im not sure works or not !?
    url = f"{baseurl}/{teamprojectcollection}/{team_id}/_api/_identity/EditMembership?__v=5" #DELETE
    payload = {"editMembers": True,
               "groupId": f"{group_id}",
               "removeItemsJson": f'["{user_id}"]',
    }
    response = requests.post(url, json=payload, headers={**headers, "Content-Type": "application/json; charset=utf-8"})
    print(response.status_code)
    if response.status_code == 200:
        return True
    else:
        print(response)
        return False

print ("Starting")

project_id = FindTeamProjectIDbyName(teamprojectname)
print(f"p id: {project_id}")
security_group_id = GetSecurityGroupIDbyTeamID(project_id)
print(f"g id: {security_group_id}")
user_id = FindUserIDbyName(username)
print (f"u id: {user_id}")
ValidateInputes()
if action == "add":
    AddUserToGroup(security_group_id, user_id, project_id)
elif action == "remove":
    RemoveUserFromeGroup(security_group_id, user_id, project_id)
