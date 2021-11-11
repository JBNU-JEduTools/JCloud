# Openstack 설치 가이드(with Devstack)
devstack을 이용해 Jcloud의 인스턴스(Ubuntu 20.04)에 OpenStack(stable/xena버전)을 설치하는 가이드입니다.

Ubuntu 버전과 설치하고자 하는 Openstack의 버전에 따라 수정이 필요합니다.

## 오픈스택을 설치하기 위한 최소 사양 확인하기
* Jcloud의 인스턴스에 설치하는 경우 그대로 따라만 하면 문제 없습니다.  
|Controller Node (Core Component)|Compute Node (Core Component)|  
|---|---|  
|CPU Processor 1-2|CPU Processor 2-4|  
|RAM 8GB|RAM 8GB|  
|Storage 100GB|Storage 100GB|  
|NIC 2|NIC 2|  

|Controller Node (Core Component)|Compute Node (Core Component)|
|------|---|
|테스트1|테스트2|
|테스트1|테스트2|
|테스트1|테스트2|
    
* 기타 다른 노드들에 대한 최소 사양도 존재합니다.
* 오픈스택 최소 사양을 검색해보면 다 다르게 나와서 어떤게 맞는지 모르겠습니다.

## 시작하기
1. 인스턴스 생성 (이미지를 첨가하면 좋을 것 같습니다.)
    1. Source 선택 - Ubuntu.20.04.2.ssh7777 (latest)
    2. Flavot 선택 - devstack.flavor
    3. Network 선택 - cse-students.network
    4. 유동 IP 설정
     
2. Openstack 설치
    1. Prerequirements 설치
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
    3. 유저 생성
         ```
         $sudo useradd -s /bin/bash -d /opt/stack -m stack
         $echo "stack ALL=(ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/stack
         $sudo su - stack
         ```
    5. Devstack 다운로드
         ```
         $sudo apt install git -y
         $git clone https://github.com/openstack-dev/devstack.git -b stable/xena
         $sudo chown -R stack ./devstack
         $sudo chmod -R 777 devstack
         ```
    7. 노드 설정 - Controller Node
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
    9. pip 수정
         ```
         $vi inc/python
         ```
         > 198번째 라인을 다음과 같이 수정합니다.  
         > from : $cmd_pip $upgrade \  
         > to: $cmd_pip $upgrade $install_test_reqs --ignore-installed \  
    10. 설치시작
         ```
         $ ./stack.sh
         ```
