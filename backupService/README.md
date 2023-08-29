
# JCloud 백업 스크립트 가이드
### JCloud 의 특정 프로젝트에 포함된 인스턴스들에 대한 백업 스크립트에 대한 가이드 문서입니다.
### [백업 스크립트 서비스의 가이드 영상](https://youtu.be/7nmM0YYfCTw)  
### [백업 스크립트 서비스의 시연 영상](https://youtu.be/SfoG8hWgPYE)

# 특징
- 백업이 수행될 때, 서버에 너무 과한 부하를 주지 않도록 대역폭을 제한 할 수 있습니다.
- 백업 서버에 유지할 수 있는 최대 백업들의 개수를 정할 수 있습니다.
- 백업 과정이 중단 되었을 때, 다시 이어서 수행 할 수 있습니다.
- 가장 최신 백업은 백업 서버로 전송하지 않습니다.
- 백업 스크립트 수행 시간을 제한 할 수 있습니다.

# 폴더 구조
```
jcloud
├── .env
├── backup.sh
```
## .env
* 백업 스크립트가 실행 되기 위해 필요한 기본 변수들이 저장 되어 있습니다.  
* **반드시 실행 환경에 맞게 변경 해 주셔야합니다.**  
* 다음은 .env 파일의 변수들에 대한 설명입니다.

| 변수 이름 | 설명                    | 예시 | 
| ------------- | ------------------------------------------------------ | ------------- |
| `PATH_TO_JOBLIST`      | 백업이 필요한 인스턴스의 ID를 저장하는 파일의 경로 | 'joblist'  |
| `PATH_TO_SNAPSHOT_DIR`   | 스냅샷 생성시 기본 저장 되는 폴더의 경로 | '/opt/stack/data/glance/images' |
| `PATH_TO_SNAPSHOT_WITH_METADATA_DIR`      | 각 인스턴스별 메타데이터가 포함된 스냅샷 폴더의 경로   | '/home/ubuntu/snapshots' |
| `PATH_TO_SNAPSHOT_BACKUP_DIR`   | 백업된 스냅샷을 접근 할 수 있는 폴더의 경로 | '/home/ubuntu/backup' |
| `PATH_TO_SNAPSHOT_BACKUP_DIR_REMOTE`      | 백업 서버에 저장된 스냅샷 폴더의 경로 | '/root/desktop' |
| `PATH_TO_PRIVATE_KEY`   | 백업 서버에 SSH 접근 할 수 있는 Key 파일의 경로 | '/home/ubuntu/.ssh/id_rsa' |
| `PATH_TO_OPENRC_FILE`   | 사용자 권한을 얻는 OPENRC 파일의 경로 | '/home/ubuntu/devstack/openrc' |
| `MAX_COUNT_OF_SNAPSHOT`   | 백업 서버에 저장 될 수 있는 최대 스냅샷의 개수 | 5 |
| `IPADDRESS_REMOTE`      | 백업 서버의 IP 주소| '203.254.143.173' |
| `USERNAME_REMOTE`   | 백업 서버의 유저 이름 | 'root' |
| `PORT_REMOTE`   | 백업 서버에 스냅샷을 전송 할 때 사용하는 포트 번호 | 7777 |
| `BANDWIDTH_LIMIT`      | 스냅샷 전송할 때 사용하는 최대 대역폭 (MB/s) | 500 |
| `TIMELIMIT`   | 백업 스크립트의 최대 수행시간 (초)| 3600 |
| `PROJECT_NAME`      | 백업 하고자 하는 JCloud 프로젝트 이름| demo |
| `ACCOUNT_NAME`   | 백업을 수행하는 JCloud 계정 ID| admin |

## backup.sh
* 프로젝트에 포함된 인스턴스들에 대한 백업을 생성하고 정책에 맞게 백업 서버에 전송합니다.  
* 다음은 백업 스크립트의 실행 과정입니다.
#### 1. 계정 권한을 얻습니다.
#### 2. 해당 프로젝트의 인스턴스 ID를 가져와 작업리스트에 추가합니다.
#### 3. 작업리스트에 있는 각 인스턴스에 대해서 4-8번을 반복합니다.
#### 4. 인스턴스를 백업하여 스냅샷을 생성합니다.
#### 5. 가장 최근 1개의 백업을 제외하고 백업서버에 전송할 스냅샷을 선택합니다.
#### 6. 선택한 스냅샷의 파일에 메타데이터를 추가하여 해당 인스턴스 폴더로 복사합니다.
#### 7. 백업 서버에 전송합니다.
#### 8. 최근 5개의 백업만 남기고 삭제합니다. 
#### 9. 작업리스트에서 완료한 인스턴스를 삭제합니다.
#### 10. 제한시간을 초과했거나, 작업목록이 비어있다면 종료합니다.

# 시작하기
## 백업 서버 설정
* 백업 서버에 저장된 스냅샷들은 backup.sh에서 접근이 가능해야 합니다.
* 이를 위해 NFS를 이용합니다.

### 1. NFS 설정
#### 1.1 NFS 서버를 위한 패키지 프로그램 설치
```
$ apt-get install nfs-common nfs-kernel-server rpcbind portmap
```
#### 1.2 공유할 폴더 생성
```
$ mkdir $PATH_TO_SNAPSHOT_BACKUP_DIR_REMOTE
$ chmod -R 777 $PATH_TO_SNAPSHOT_BACKUP_DIR_REMOTE
```
#### 1.3 NFS 설정 수정

* 설정 파일은 `/etc/exports` 파일입니다.
* 아래는 NFS를 걸 폴더는 /mnt/data이고, 203.254.143.192에 대해 다 열겠다는 뜻입니다.
```
# /etc/exports 파일 예시 
/mnt/data 203.254.143.192(rw,sync,no_subtree_check)
```
#### 1.4 반영
```
$ exportfs -a
$ systemctl restart nfs-kernel-server
```
## JCloud 서버 설정
### 1. Openstack 설치
* JCloud 서버에는 openstack이 설치되어있어야 합니다.
* 설치 방법은 아래 문서를 참고하세요.
* [Openstack 설치방법](https://github.com/hyunchan-park/jcloud/blob/main/InstallationGuide.md)

### 2. NFS 설정
#### 2.1 NFS 클라이언트를 위한 패키지 프로그램 설치
```
$ apt-get install nfs-common
```

#### 2.2 NFS 마운트할 폴더 생성
```
$ mkdir $PATH_TO_SNAPSHOT_BACKUP_DIR
```

#### 2.3 마운트
NFS 서버 IP가 172.31.2.2라고 가정해보겠습니다.
```
$ mount 172.31.2.2:$PATH_TO_SNAPSHOT_BACKUP_DIR_REMOTE $PATH_TO_SNAPSHOT_BACKUP_DIR
```

### 3. SSH key 설정
* backup.sh는 rsync를 이용하여 스냅샷을 전송하는데 내부적으로는 ssh를 사용합니다.  
* SSH key를 설정하여 반복적으로 비밀번호를 물어보는 현상을 방지해야 합니다.
#### 3.1 key 생성
```
$ ssh-keygen
```
#### 3.2 backup 서버에 키 전송
```
$ ssh-copy-id "-p $PORT_REMOTE $USERNAME_REMOTE@$IPADDRESS_REMOTE"
```

## backup.sh 실행
* 실행 권한을 부여하고 실행합니다.
```
$ chmod +x backup.sh
$ ./backup.sh
```

## 보완할 점
- 해당 스크립트는 프로젝트 이름에 연속된 2개의 underline이 포함하고 있지 않다는 것을 가정합니다.  해당 문자열이 포함된 프로젝트 이름에 대해서 백업스크립트를 실행하는 것은 권장하지 않습니다. 
