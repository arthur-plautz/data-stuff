from sys import argv
import requests

target = argv[1]

url = 'http://localhost:8083/connectors/'
headers = {
    "accept": "application/json",
    "content-type": "application/json"
}
payload = open(f'{target}-connector.json')

response = requests.post(url, headers=headers, data=payload)
print(response.text)