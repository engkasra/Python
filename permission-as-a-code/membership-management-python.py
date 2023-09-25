import requests
import base64
import json
import sys
from enum import Enum

#enum use for advance and optimize code, if we have many options in action variable
# class ActionList(Enum):
#     add = 1
#     delete = 2

# Step 1 _ Input Data Into The Variables ###


print("Argument List:", str(sys.argv))

if len(sys.argv) != 8:
    print(f"Error: Expected parameters count is 8 but tou provide {len(sys.argv)}")
    exit(1)

baseurl = sys.argv[1] # "https://azure.asax.ir/tfs" # or input ('Azure DevOps Url: ')
teamprojectcollection = sys.argv[2] # "AsaProjects" # or input ('Team Project Collection Name: ')
teamprojectname =  sys.argv[3] # "${{ parameters.TeamprojectName }}" # input ('TeamProject: ')
action =  sys.argv[4] # "${{ parameters.Action }}" # input ('Enter Action (add or remove): ')
username =  sys.argv[5] # "${{ parameters.Username }}" # input ('Enter username to add/remove: ')
groupname =  sys.argv[6] # "${{ parameters.GroupName }}" # input ('Enter Groupname to add/remove to/from: ')
pat =  sys.argv[7] # "$(manage-permission-pat)" # input ('Enter Authentication Token: ')


# Step 3 _ Check Valid Data In Variables ###

def ValidateInputes():
    print('Starting ValidateInputes')
    allowed_action = "add", "remove"
    if action.lower() not in allowed_action:
        print ("Error: input for action parameters is invalid. Allowed inputes are 'add' and 'remove'")
        exit(2)
    if username == "":
        print("Error: please enter your Asax domain user")
        exit(3)
    if teamprojectname == "":
        print("Error: please enter valid team project name")
        exit(4)
    if groupname == "":
        print("Error: please enter valid group name in teamproject that you want to edit")
        exit(5)
    if len(pat) == 0:
        print("Error: manage-permission-pat is empty")
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

ValidateInputes()
            
# Step 2 _ Set The Request Headers And Encode The Personal Access Token ###
headers = {
"Authorization": "Basic " + base64.b64encode(bytes(":" + pat, "ascii")).decode("ascii")
}

project_id = FindTeamProjectIDbyName(teamprojectname)
print(f"p id: {project_id}")
security_group_id = GetSecurityGroupIDbyTeamID(project_id)
print(f"g id: {security_group_id}")
user_id = FindUserIDbyName(username)
print (f"u id: {user_id}")


if action == "add":
    AddUserToGroup(security_group_id, user_id, project_id)
elif action == "remove":
    RemoveUserFromeGroup(security_group_id, user_id, project_id)