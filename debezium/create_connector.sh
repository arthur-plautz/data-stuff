curl -i -X POST \
 -H "Accept:application/json" \
 -H "Content-Type:application/json" \
 localhost:8083/connectors/ \
 -d "$(cat pg-connector.json)"