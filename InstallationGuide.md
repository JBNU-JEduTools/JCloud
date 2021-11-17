# Openstack 설치 가이드(with Devstack All-In-One Single Machine)
Devstack을 이용해 Jcloud의 인스턴스(Ubuntu 20.04)에 OpenStack(stable/xena버전)을 설치하는 가이드입니다.  
Ubuntu 버전과 설치하고자 하는 Openstack의 버전에 따라 수정이 필요합니다.  
인스턴스 생성과 오픈스택 설치 과정에 있어 이미지를 추가해준다면 더 좋을것 같습니다.  
또한 실행 코드들의 불필요한 부분의 제거가 필요할 수 있습니다.  

이 가이드는 오픈스택 공식 문서의 [All-In-One Single Machine 가이드](https://docs.openstack.org/devstack/rocky/guides/single-machine.html)를 참고했습니다.

>[All-In-One-Single VM 가이드](https://docs.openstack.org/devstack/rocky/guides/single-vm.html)가 존재하지만 우리는 cloud-init 기능을 사용하지 않기 때문에 All-In-One Single Machine 가이드를 참고합니다. 


## 오픈스택을 설치하기 위한 최소 사양 확인하기
* 핵심 노드들에 대한 정보만을 담았으며 기타 노드들에 대한 최소 사양도 존재합니다.  
* Jcloud의 인스턴스에 설치하는 경우 그대로 따라만 하면 문제 없습니다.  
* 오픈스택 설치를 위한 최소 사양은 버전마다 달라질 수 있습니다.    

|Controller Node (Core Component)|Compute Node (Core Component)|
|------|---|
|CPU Processor 1-2|CPU Processor 2-4|
|RAM 8GB|RAM 8GB|
|Storage 100GB|Storage 100GB|
|NIC 2|NIC 2|   


# 시작하기  
## 1. 인스턴스 생성
### 1.1 Source 선택  
* Ubuntu.20.04.2.ssh7777 (latest)   
### 1.2 Flavor 선택  
* devstack.flavor  
> *devstack.flavor* 사용을 위해서는 *jcloud@jbnu.ac.kr*로 메일을 보내 승인을 받아주세요.  
### 1.3 Network 선택  
* cse-students.network  
### 1.4 유동 IP 설정  
> *유동 IP* 사용을 위해서는 *jcloud@jbnu.ac.kr*로 메일을 보내 승인을 받아주세요.  
     
----------------------------     
## 2. Openstack 설치
### 2.1 Prerequirements 설치
 ```
 $sudo su - root 

 #apt update
 #apt upgrade -y
 #apt purge python3-simplejson -y
 #apt autoremove -y
 #apt install python-simplejson -y
 #apt install python-pip
 #apt install python-dev
 #apt install libxml2-dev
 #apt install libxslt-dev
 #apt install libffi-dev
 #apt install libpq-dev
 #apt install python-openssl
 #apt install mysql-client

 #reboot
 ```

**[참고]**
     
apt install python-pip 수행 시 아래와 같은 에러가 뜰 수 있습니다.
     
<em>``` E: Unable to locate package python-pip ```</em>

python-pip는 2.6절에서 ./stack.sh 수행 시 python-pip 의존성을 자동으로 설치해주기 때문에 생략해도 무방합니다.

## 2.2 유저 생성
 ```
 $sudo useradd -s /bin/bash -d /opt/stack -m stack
 $echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
 $sudo su - stack
 ```
### 2.3 Devstack 다운로드
 ```
 $sudo apt install git -y
 $git clone https://github.com/openstack-dev/devstack.git -b stable/xena
 $sudo chown -R stack ./devstack
 $sudo chmod -R 777 devstack
 ```
### 2.4 노드 설정 - Controller Node
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
### 2.5 pip 수정
 ```
 $vi inc/python
 ```
 > 198번째 라인을 다음과 같이 수정합니다. (198입력후 shift + g로 이동)  
 > from : $cmd_pip $upgrade \  (변경하고자 하는 부분은 버전마다 다를 수 있습니다.)  
 > to: $cmd_pip $upgrade $install_test_reqs --ignore-installed \  
### 2.6 설치시작
 ```
 $ ./stack.sh
 ```
----------------------------
## 3. 설치 확인
* 교내 - 할당받은 유동 IP인 `http://203.254.143.XXX/`로 접속
* 외부 - `http://203.254.143.217:18XXX/`로 접속  
  XXX는 본인 인스턴스의 주소 마지막 3자리 *ex) 118 -> 18118, 13 -> 18013, 1 -> 18001*
     
**[참고]**
     
위의 `203.254.143.217` ip 주소는 JCloud project의 External Gateway 주소입니다. 만약 다른 project에서 구축했다면 이 ip 주소를 적절하게 해당 프로젝트의 External Gateway로 바꿔주세요.
     
----------------------------
     
## 4. VM 생성
     
테스트를 위해 [인스턴스를 생성](https://jcloud-devops.github.io/user-guide.html)해봅시다. 정상적으로 생성되었다면 올바르게 OpenStack을 구축한 것입니다.


