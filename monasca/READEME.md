# Monasca installation
## 1. requirement
- OS: ubuntu 18.04LTS(Bionic)
- CPU: VCPU processor 4개 이상 
- RAM: 8GB 이상
- Storage: 20GB이상
- openstack: wallaby
## 2. installation
### 1. [devstack installtion guide](https://github.com/hyunchan-park/jcloud/blob/main/InstallationGuide.md)
설치시 ubuntu18.04LTS로 시작해야하고 xena가 아닌 wallaby 버전을 적용 해야 하므로 
2.3 Devstack 다운로드 부분부터 밑에내용으로 변경해서 적용
### 2. Devstack 다운 및 노드 설정
2-1. Devstack 다운로드
```
$sudo apt install git -y
$git clone https://github.com/openstack-dev/devstack.git -b stable/wallaby
$sudo chown -R stack ./devstack
$sudo chmod -R 777 devstack
```
2-2. 노드 설정
```
$cd devstack
$vi local.conf
```
**local.conf**
> [[local|localrc]]  
> HOST_IP=<IP> # hostname -I 를 통해 얻은 IP  
> ADMIN_PASSWORD=0000  
> RABBIT_PASSWORD=0000  
> SERVICE_PASSWORD=0000  
> DATABASE_PASSWORD=0000
>
> LOGFILE=$DEST/logs/stack.sh.log   
> LOGDIR=$DEST/logs   
> LOG_COLOR=False   
> GIT_BASE=https://opendev.org    
>
> MONASCA_API_IMPLEMENTATION_LANG=${MONASCA_API_IMPLEMENTATION_LANG:-python}
> MONASCA_PERSISTER_IMPLEMENTATION_LANG=${MONASCA_PERSISTER_IMPLEMENTATION_LANG:-python}
> MONASCA_METRICS_DB=${MONASCA_METRICS_DB:-influxdb}
> enable_plugin monasca-api https://opendev.org/openstack/monasca-api stable/wallaby
  
