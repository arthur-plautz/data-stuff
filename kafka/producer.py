from kafka import KafkaProducer
from json import dumps

producer = KafkaProducer(
   value_serializer=lambda m: dumps(m).encode('utf-8')
)

producer.send("test", value={"hello": "producer"})
producer.flush()