# Monasca Manual installation
모나스카를 처음부터 끝까지 설치하는 메뉴얼
## requirement
- OS: ubuntu 20.04LTS(Focal)
- CPU: VCPU processor 4개 이상 
- RAM: 8GB 이상
- Storage: 20GB이상
- openstack: xena
## installation

### 사전준비
#### 1. install jdk8 & python
```
 $ sudo add-apt-repository ppa:openjdk-r/ppa
 $ sudo apt-get update
 $ sudo apt-get install openjdk-8-jdk python-pip python-dev
```
#### 2. install Maven
```
 $ sudo apt-get install maven
```
#### 3. install uwsgi
```
$ pip install uwsgi
```
#### 4. mon쿼리 db 등록

https://drive.google.com/file/d/1XCaG5-SzLAjIXWvG163VfD1XkWpwE75K/view?usp=sharing

> 위 주소에 있는 파일은 다운로드 한다.
```
$ mysql –u root –p”패스워드” < mon_mysql.sql
```

### Apache Kafka & Zookeeper 설치
#### 1. kafka 압축 해제후에 경로지정해줌
```
$ wget https://archive.apache.org/dist/kafka/2.6.0/kafka_2.12-2.6.0.tgz
$ tar zxf kafka_2.12-2.6.0.tgz
$ mv kafka_2.12-2.6.0.tgz kafka
$ sudo mv kafka /opt/
```
#### 2. kafka 설정
```
$ vi /etc/kafka/server.properties
---
############################# Server Basics #############################
broker.id=0
log.dirs=/opt/kafka/logs
############################# Socket Server Settings #############################
num.network.threads=3
num.io.threads=8
socket.send.buffer.bytes=102400
socket.receive.buffer.bytes=102400
socket.request.max.bytes=104857600
############################# Log Basics #############################
log.dirs=/tmp/kafka-logs
num.partitions=1
num.recovery.threads.per.data.dir=1
############################# Internal Topic Settings  #############################
offsets.topic.replication.factor=1
transaction.state.log.replication.factor=1
transaction.state.log.min.isr=1
############################# Log Retention Policy #############################
log.retention.hours=168
log.segment.bytes=1073741824
log.retention.check.interval.ms=300000
############################# Zookeeper #############################
zookeeper.connect=localhost:2181
zookeeper.connection.timeout.ms=18000
############################# Group Coordinator Settings #############################
group.initial.rebalance.delay.ms=0
```
#### 3. 권한 및 사용자 추가
```
$ sudo useradd kafka -U -r
$ sudo mkdir /var/kafka
$ sudo mkdir /opt/kafka/logs
$ sudo chown -R kafka. /var/kafka/
$ sudo chown -R kafka. /opt/kafka/logs
```
#### 4. 서비스 파일 작성 및 시작
```

```
#### 5. 토픽 생성
```
$ /opt/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 32 --topic metrics
$ /opt/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 6 --topic events
$ /opt/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 6 --topic alarm-state-transitions
$ /opt/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 6 --topic alarm-notifications
$ /opt/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 3 --topic retry-notifications
$ /opt/kafka/bin/kafka-topics.sh --create --zookeeper localhost:2181 --replication-factor 1 --partitions 3 --topic 60-seconds-notifications
```
#### 6. 토픽 확인
```
$ /opt/kafka/bin/kafka-topics.sh --list --zookeeper localhost:2181
```

### Apache Storm 설치
#### 1. storm 다운 및 경로지정
```
$ wget ...
```
#### 2. storm 설정 수정
```
$ sudo vi /opt/storm/conf/storm.yaml
```
#### 3. 권한 및 사용자 추가
```
$ sudo useradd storm -U -r
$ sudo mkdir /var/storm
$ sudo mkdir /opt/storm/logs
$ sudo chown -R storm. /var/storm
$ sudo chown -R storm. /opt/storm/logs
```
#### 4. storm 서비스 작성 및 시작
```
...
```
#### 5. 로그 확인
```
...
```
### InfluxDB 설치
#### 1. InfluxDB repository 등록
```
$ sudo apt-get update
$ curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -
$ echo "deb https://repos.influxdata.com/ubuntu focal stable" | sudo tee /etc/apt/sources.list.d/influxdb.list
```
#### 2. InfluxDB 및 관련 dependencies 설치
```
$ sudo apt-get update
$ sudo apt-get install -y influxdb
$ sudo apt-get install -y apt-transport-https
```
#### 3. InfluxDB 서비스 시작
```
$ sudo service influxdb start
```
#### 4. 메트릭 관련 데이터베이스 생성 및 정책 등록
```
$  influx
Connected to http://localhost:8086 version 1.3.1
InfluxDB shell version: 1.3.1
> CREATE DATABASE mon
> CREATE USER monasca WITH PASSWORD 'password'
> CREATE RETENTION POLICY persister_all ON mon DURATION 90d REPLICATION 1 DEFAULT
> quit
   # Alarm 관련 정보를 관리하기 위한 데이터베이스 생성 및 관리자 정보 등록
```
### Monasca Persister 설치
#### 1. Monasca Persister 설치
```
$ sudo pip install --upgrade pbr
$ sudo pip install influxdb
$ git clone https://opendev.org/openstack/monasca-persister.git -b stable/xena
$ pip install -c https://releases.openstack.org/constraints/upper/xena -e ./monasca-persister
```
#### 2. configuration 파일 생성
```
$ sudo vi /etc/monasca/persister.conf
[DEFAULT]
debug = True
default_log_levels = monasca_common.kafka_lib.client=INFO
logging_exception_prefix = ERROR %(name)s %(instance)s
logging_default_format_string = %(color)s%(levelname)s %(name)s [-%(color)s] %(instance)s%(color)s%(message)s
logging_context_format_string = %(color)s%(levelname)s %(name)s [%(global_request_id)s %(request_id)s %(project_name)s %(user_name)s%(color)s] %(instance)s%(color)s%(message)s
logging_debug_format_suffix = {{(pid=%(process)d) %(funcName)s %(pathname)s:%(lineno)d}}
use_syslog = False

[repositories]
# The driver to use for the metrics repository
metrics_driver = monasca_persister.repositories.influxdb.metrics_repository:MetricInfluxdbRepository
#metrics_driver = monasca_persister.repositories.cassandra.metrics_repository:MetricCassandraRepository

# The driver to use for the alarm state history repository
alarm_state_history_driver = monasca_persister.repositories.influxdb.alarm_state_history_repository:AlarmStateHistInfluxdbRepository
#alarm_state_history_driver = monasca_persister.repositories.cassandra.alarm_state_history_repository:AlarmStateHistCassandraRepository

[zookeeper]
# Comma separated list of host:port
uri = 10.0.0.106:2181
partition_interval_recheck_seconds = 15

[kafka_alarm_history]
# Comma separated list of Kafka broker host:port.
uri = 10.0.0.106:9092
group_id = 1_alarm-state-transitions
topic = alarm-state-transitions
consumer_id = consumers
client_id = 1
database_batch_size = 1000
max_wait_time_seconds = 30
# The following 3 values are set to the kakfa-python defaults
fetch_size_bytes = 4096
buffer_size = 4096
# 8 times buffer size
max_buffer_size = 32768
# Path in zookeeper for kafka consumer group partitioning algo
zookeeper_path = /persister_partitions/alarm-state-transitions
num_processors = 1

[kafka_metrics]
# Comma separated list of Kafka broker host:port
uri = 10.0.0.106:9092
group_id = 1_metrics
topic = metrics
consumer_id = consumers
client_id = 1
database_batch_size = 1000
max_wait_time_seconds = 30
# The following 3 values are set to the kakfa-python defaults
fetch_size_bytes = 4096
buffer_size = 4096
# 8 times buffer size
max_buffer_size = 32768
# Path in zookeeper for kafka consumer group partitioning algo
zookeeper_path = /persister_partitions/metrics
num_processors = 1

[influxdb]
database_name = mon                          
ip_address = 10.0.0.106                      
port = 8086                                    
user = monasca                                 
password = password 
```
### Monasca Common 설치
#### 1. monasca common 다운로드
```
$ git clone -b stable/xena https://github.com/openstack/monasca-common
$ cd monasca-common
```
#### 2-1. monasca common python 설치
```
$ sudo python setup.py install
```
#### 2-2. monasca common java 설치
```
$ cd java
$ mvn clean install
```
SNAPSHOT 버전 확인 및 기억
### Monasca Thresh 설치
#### 1. monasca thresh 다운로드
```
$ git clone -b stable/xena https://github.com/openstack/monasca-thresh
$ cd monasca-thresh
```
#### 2. monasca thresh 오픈소스 compile and package
```
$ ./run_maven.sh [기억해놓은 monasca common 버전]-SNAPSHOT clean package
```
#### 3. 생성된 monasca thresh package 압축해제 및 configuration 파일 수정
```
$ cd target

# 생성된 monasca-thres package 파일명에 생성일자가 있어 압축해제 명령어가 실행되지 않는다.
# 생성된 package 명을 monasca-thresh-2.1.1-SNAPSHOT.tar.gz 로 변경한다.
$ mv  monasca-thresh-2.1.1-SNAPSHOT-2017-xx-xxT00:20:08-5c1fd5-tar.tar.gz monasca-thresh-2.1.1-SNAPSHOT.tar.gz

$ tar xvzf monasca-thresh-2.1.1-SNAPSHOT.tar.gz

# 압축해제된 디렉토리도 위와 같이 변경한다.
$ mv  monasca-thresh-2.1.1-SNAPSHOT-2017-xx-xxT00:20:08-5c1fd5 monasca-thresh-2.1.1-SNAPSHOT
$ cd monasca-thresh-2.1.1-SNAPSHOT
$ cd examples
$ mv thresh-config.yml-sample thresh-config.yml
$ vi thresh-config.yml
---
metricSpoutThreads: 2
metricSpoutTasks: 2

statsdConfig:
  host: localhost
  port: 8125
  prefix: monasca.storm.
  dimensions: !!map
    service : monitoring
    component : storm


metricSpoutConfig:
  kafkaConsumerConfiguration:
  # See http://kafka.apache.org/documentation.html#api for semantics and defaults.
    topic: metrics
    numThreads: 1
    groupId: thresh-metric
    zookeeperConnect: localhost:2181
    consumerId: 1
    socketTimeoutMs: 30000
    socketReceiveBufferBytes : 65536
    fetchMessageMaxBytes: 1048576
    autoCommitEnable: true
    autoCommitIntervalMs: 60000
    queuedMaxMessageChunks: 10
    rebalanceMaxRetries: 4
    fetchMinBytes:  1
    fetchWaitMaxMs:  100
    rebalanceBackoffMs: 2000
    refreshLeaderBackoffMs: 200
    autoOffsetReset: largest
    consumerTimeoutMs:  -1
    clientId : 1
    zookeeperSessionTimeoutMs : 60000
    zookeeperConnectionTimeoutMs : 60000
    zookeeperSyncTimeMs: 2000


eventSpoutConfig:
  kafkaConsumerConfiguration:
  # See http://kafka.apache.org/documentation.html#api for semantics and defaults.
    topic: events
    numThreads: 1
    groupId: thresh-event
    zookeeperConnect: localhost:2181
    consumerId: 1
    socketTimeoutMs: 30000
    socketReceiveBufferBytes : 65536
    fetchMessageMaxBytes: 1048576
    autoCommitEnable: true
    autoCommitIntervalMs: 60000
    queuedMaxMessageChunks: 10
    rebalanceMaxRetries: 4
    fetchMinBytes:  1
    fetchWaitMaxMs:  100
    rebalanceBackoffMs: 2000
    refreshLeaderBackoffMs: 200
    autoOffsetReset: largest
    consumerTimeoutMs:  -1
    clientId : 1
    zookeeperSessionTimeoutMs : 60000
    zookeeperConnectionTimeoutMs : 60000
    zookeeperSyncTimeMs: 2000


kafkaProducerConfig:
  # See http://kafka.apache.org/documentation.html#api for semantics and defaults.
  topic: alarm-state-transitions
  metadataBrokerList: localhost:9092
  serializerClass: kafka.serializer.StringEncoder
  partitionerClass:
  requestRequiredAcks: 1
  requestTimeoutMs: 10000
  producerType: sync
  keySerializerClass:
  compressionCodec: none
  compressedTopics:
  messageSendMaxRetries: 3
  retryBackoffMs: 100
  topicMetadataRefreshIntervalMs: 600000
  queueBufferingMaxMs: 5000
  queueBufferingMaxMessages: 10000
  queueEnqueueTimeoutMs: -1
  batchNumMessages: 200
  sendBufferBytes: 102400
  clientId : Threshold_Engine


sporadicMetricNamespaces:
  - foo

database:
  driverClass: com.mysql.jdbc.Driver
  url: jdbc:mysql://localhost/mon?useSSL=true
  user: root
  password: openstack
  properties:
      ssl: false
  # the maximum amount of time to wait on an empty pool before throwing an exception
  maxWaitForConnection: 1s

  # the SQL query to run when validating a connection's liveness
  validationQuery: "/* MyService Health Check */ SELECT 1"

  # the minimum number of connections to keep open
  minSize: 8

  # the maximum number of connections to keep open


  maxSize: 41

  hibernateSupport: False

  # hibernate provider class
  providerClass: com.zaxxer.hikari.hibernate.HikariConnectionProvider

  # database name
  databaseName: mon

  # server name/address
  serverName: 127.0.0.1

  # server port number
  portNumber: 3306

  # hibernate auto configuretion parameter
  autoConfig: validate
```
#### 4. monasca thresh configuration 및 package 파일 이동
```
$ sudo mv thresh-config.yml /etc/monasca/
$ cd ..
$ mv monasca-thresh.jar /etc/monasca/
```
#### 5. 서비스 스크립트 생성 및 시작
```
...
```
#### 6. 로그 확인
```
$ ps -ef |grep thresh
```
### Monasca Notification 설치
#### 1. monasca notification 다운로드 및 dependencies 설치
```
$ git clone https://github.com/openstack/monasca-notification.git -b stable/xena
$ sudo apt-get install sendmail
$ cd monasca-notification
```
#### 2. monasca notificatioin 설정 파일 생성
```
$ tox -e genconfig
$ sudo mv etc/monasca/notification.conf.sample /etc/monasca/notification.conf
$ sudo vi /etc/monasca/notification.conf
---
[database]
repo_driver = monasca_notification.common.repositories.mysql.mysql_repo:MysqlRepo

[email_notifier]
from_addr = 201716403@jbnu.ac.kr
server = 10.0.0.106
port = 25
timeout = 60

[kafka]
url = 10.0.0.106:9092
group = monasca-notification
alarm_topic: alarm-state-transitions
notification_topic: alarm-notifications
notification_retry_topic: retry-notifications
periodic = 60:60-seconds-notifications
max_offset_lag = 600

[keystone]
auth_url = http://10.0.0.106/identity/v3

[mysql]
host = 127.0.0.1
user = root
passwd = openstack
db = mon

[notification_types]
enabled = email,webhook

[webhook_notifier]
timeout = 5

[zookeeper]
url = 127.0.0.1:2181
```
#### 3. 로그 디렉토리 생성
```
$ sudo mkdir -p /var/log/monasca/notification
$ sudo chown -R monasca. /var/log/monasca/notification
```
#### 4. 서비스 스크립트 생성 및 시작
```
...
```
#### 5. 확인
```
$ ps -ef |grep notification
```
### Monasca API 설치
#### 1. monasca api 다운로드
```
$ git clone -b stable/xena https://github.com/openstack/monasca-api
$ cd monasca-api 
```
#### 2. monasca api Python 설치
```
$ sudo python setup.py install
```
#### 3. monasca api configuration
```
$ sudo vi /etc/monasca/monasca-api.conf
---
[DEFAULT]
enable_logs_api = true
log_config_append = /etc/monasca/api-logging.conf
region = RegionOne

[cassandra]
contact_points = 10.0.0.106

[database]
connection = mysql+pymysql://root:openstack@127.0.0.1/mon?charset=utf8

[influxdb]
port = 8086
ip_address = 10.0.0.106

[kafka]
logs_topics = log
uri = 10.0.0.106:9092

[keystone_authtoken]
region_name = RegionOne
memcached_servers = localhost:11211
#cafile = /opt/stack/data/ca-bundle.pem
project_domain_name = Default
project_name = admin
user_domain_name = Default
password = openstack
username = admin
auth_url = http://10.0.0.106/identity
interface = public
auth_type = password

[messaging]
driver = monasca_api.common.messaging.kafka_publisher:KafkaPublisher

[repositories]
metrics_driver = monasca_api.common.repositories.influxdb.metrics_repository:MetricsRepository

[security]
delegate_authorized_roles = admin, monasca-agent
read_only_authorized_roles = admin, monasca-read-only-user
agent_authorized_roles = admin, monasca-agent
default_authorized_roles = admin, monasca-user
```
#### 4. api uwsgi 설정
```
$ sudo vi api-uwsgi.ini
---
[uwsgi]
wsgi-file = /usr/local/bin/monasca-api-wsgi

# Versions of mod_proxy_uwsgi>=2.0.6 should use a UNIX socket, see
# http://uwsgi-docs.readthedocs.org/en/latest/Apache.html#mod-proxy-uwsgi
uwsgi-socket = 127.0.0.1:8070

# Override the default size for headers from the 4k default.
buffer-size = 65535

# This is running standalone
master = true

enable-threads = true

# Tune this to your environment.
processes = 4

# uwsgi recommends this to prevent thundering herd on accept.
thunder-lock = true

plugins = http.python3

# This ensures that file descriptors aren't shared between keystone processes.
lazy-apps = true

chmod-socket = 666

socket = /var/run/uwsgi/monasca-api-wsgi.socket
```
#### 5. site-enabled에 monasca api 등록
```
$ cd /etc/apache2/sites-enabled
$ vi monasca-api-wsgi.conf
---
ProxyPass "/metrics" "unix:/var/run/uwsgi/monasca-api-wsgi.socket|uwsgi://uwsgi-uds-monasca-api-wsgi" retry=0
ProxyPass "/metrics" "unix:/var/run/uwsgi/monasca-api-wsgi.socket|uwsgi://uwsgi-uds-monasca-api-wsgi" retry=0
ProxyPass "/metrics" "unix:/var/run/uwsgi/monasca-api-wsgi.socket|uwsgi://uwsgi-uds-monasca-api-wsgi" retry=0
```
#### 6. 서비스 스크립트 생성 및 시작
```
...
```
#### 7. 확인
```
$ ps -aux | grep monasca
```
### Monasca UI 설치

### Monasca Agent 설치
