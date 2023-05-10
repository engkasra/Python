import requests


######    Constants     ########

INSTANCE = "stageazure.asax.ir/tfs"
COLLECTION = "AsaProjects"

ACCESS_TOKEN = "<Your-personal-access-Token>"

BASE_URL = f"https://{INSTANCE}/{COLLECTION}/_apis"

#################################

url = f"{BASE_URL}/distributedtask/pools?api-version=6.0"

payload = {}
headers = {
  'Authorization': f'Basic {ACCESS_TOKEN}'
}


response = requests.request("GET", url, headers=headers, data=payload)

json_data = response.json()["value"]

for agent_pool in json_data:
    agent_pool_name = agent_pool["name"]
    agent_pool_id = agent_pool["id"]

    url = f"{BASE_URL}/distributedtask/pools/{agent_pool_id}/agents?api-version=6.0"

    response = requests.get(url=url, headers=headers)

    json_data = response.json()["value"]

    print(f"Agent Pool {agent_pool_name}:")
    
    for agent in json_data:
        agent_name = agent["name"]

        if agent["enabled"]:
            is_enabled = "Enabled"
        else:
            is_enabled = "Disabled"
        
        # is_enabled = "Enabled" if agent["enabled"] else "Disabled"
        
        status = agent["status"]

        print(f"\tAgent {agent_name} is {is_enabled} and {status}")
    
    print("-"*10)
