import requests
import base64
######    Constants     ########
INSTANCE = "azure.asax.ir/tfs"
COLLECTION = "AsaProjects"

ACCESS_TOKEN = "<Your-personal-access-Token>"

BASE_URL= f"https://{INSTANCE}/{COLLECTION}/_apis"
url_teamproject = f"{BASE_URL}/teams?api-version=6.0-preview.3"
#################################
# Step 1 get all team project
payload = {}
headers = {"Authorization": "Basic " + base64.b64encode(bytes(":" + ACCESS_TOKEN, "ascii")).decode("ascii")}
response = requests.get(url=url_teamproject, headers=headers)
json_data_teamproject=response.json()["value"]
# Step 2 List Deployment Groups
for teamproject_list in json_data_teamproject:
    API_ListDeploymentGroup=f"https://{INSTANCE}/{COLLECTION}/{teamproject_list['projectId']}/_apis/distributedtask/deploymentgroups?api-version=6.0-preview.1"
    response = requests.get(url=API_ListDeploymentGroup, headers=headers)
    json_data_deploymentgroup = response.json()["value"]
    print(f"DeploymentGroups*{teamproject_list['name']}*")
# Step 3 list data in each deployment
    for index_dict in json_data_deploymentgroup:
        # print(f"\t OrderManagement Deployment Name: {index_dict['name']}")
        # print("*"*10)
        API_GetEachDeployment=f"https://{INSTANCE}/{COLLECTION}/{teamproject_list['projectId']}/_apis/distributedtask/deploymentgroups/{index_dict['id']}?api-version=6.0-preview.1"
        response= requests.get(url=API_GetEachDeployment, headers=headers)
        json_data_into_deployment=response.json()["machines"]
        print(f"In {teamproject_list['name']} Deployment Name: {index_dict['name']}")
        states_deploy=json_data_into_deployment[0]["agent"]
        print(f"\tEnable: {states_deploy['enabled']} , Status: {states_deploy['status']}")
        print("---"*10)
    print("#~~~~#~~~~#"*5)
