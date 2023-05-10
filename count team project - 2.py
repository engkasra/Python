import requests
import base64
import json
 # Set the API endpoint URL and personal access token
url = "https://azure.asax.ir/tfs/AsaProjects/_apis/teams?api-version=6.0-preview.3"
pat = "b4obysp27jqhwijhe5zumfjnppkpw4p5xenqkgcx7lealenfu4ya"
# Set the request headers and encode the personal access token
headers = {
"Authorization": "Basic " + base64.b64encode(bytes(":" + pat, "ascii")).decode("ascii")
}
# Send a GET request to the API endpoint and retrieve the response
response = requests.get(url, headers=headers)
# Check the response status code
if response.status_code == 200:
    json_data = response.json()
    json_data_value = json_data["value"]
    #print(json_data_value)
    json_data_count = json_data["count"]
    print("Total Team Projects:",json_data_count)
    for data in json_data_value:
        for key in data.keys():
             print(f"{key}: {data[key]}")
        print(data)
        print ("*"*15)
        #  print(f"{data[key]}")
else:
   print(f"Failed to retrieve agent queues: {response.status_code} - {response.reason}")