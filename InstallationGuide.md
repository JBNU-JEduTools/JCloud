# Openstack 설치 가이드(with Devstack)
devstack을 이용해 Jcloud의 인스턴스(Ubuntu 20.04)에 OpenStack(stable/xena버전)을 설치하는 가이드입니다.
 Ubuntu 버전과 설치하고자 하는 Openstack의 버전에 따라 수정이 필요합니다.

## 시작하기
오픈스택을 설치하기 위한 최소 사양 확인하기
* Controller Node (Core Component)
    * CPU Processor 1-2
    * RAM 8GB
    * Storage 100GB
    * NIC 2
* Compute Node (Core Component)
    * CPU Processor 2-4
    * RAM 8GB
    * Storage 100GB
    * NIC 2
    * 기타 다른 노드들에 대한 최소 사양도 존재합니다.
    * 오픈스택 최소 사양을 검색해보면 다 다르게 나와서 어떤게 맞는지 모르겠습니다.
* Jcloud의 인스턴스에 설치하는 경우 그대로 따라만 하면 문제 없습니다.

1. 인스턴스 생성
이미지
    1. Source 선택
    이미지
    2. Flavot 선택
    이미지
    3. Network 선택
    이미지 및 유동 IP 설정
    
2. Openstack 설치
    1. Prerequirements
    2. 유저 생성
    3. Devstack 다운로드
    4. 노드 설정 - Controller Node
    5. pip 수정
    6. 설치시작
