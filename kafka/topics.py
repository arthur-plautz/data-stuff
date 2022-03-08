import os

docker_cmd = "docker exec -it kafka /bin/sh"
create_cmd = "opt/kafka/bin/kafka-topics.sh --create"

def create_topic(topic, partitions=1, replication_factor=1):
    zookeeper_conn = "zookeeper:2181"
    cmd = f"""
        {docker_cmd} \
        {create_cmd} \
        --zookeeper {zookeeper_conn} \
        --replication-factor {replication_factor} \
        --partitions {partitions} \
        --topic {topic}
    """
    os.system(cmd)

create_topic('test')