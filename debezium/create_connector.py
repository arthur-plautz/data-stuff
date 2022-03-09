import requests

url = 'http://localhost:8083/connectors/'
headers = {
    "accept": "application/json",
    "content-type": "application/json"
}
payload = open('postgres-connector.json')

response = requests.post(url, headers=headers, data=payload)
print(response.text)