import os
from kafka import KafkaConsumer
from json import loads

kafka_port = os.environ.get('KAFKA_PORT')

consumer = KafkaConsumer(
   'northwind_cdc.public.us_states',
    bootstrap_servers=[f'localhost:{kafka_port}'],
    value_deserializer=lambda m: loads(m.decode('utf-8'))
)

for m in consumer:
    print(m.value.get('payload'))