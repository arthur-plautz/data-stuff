
from kafka import KafkaConsumer
from json import loads

consumer = KafkaConsumer(
   'test',
    value_deserializer=lambda m: loads(m.decode('utf-8'))
)

for m in consumer:
    print(m.value)