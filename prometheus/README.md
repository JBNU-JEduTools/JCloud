# Prometheus installation
## 1. requirement
- OS: ubuntu 20.04LTS(Focal)
- CPU: VCPU processor 4개 이상 
- RAM: 8GB 이상
- Storage: 20GB이상
## 2. installation
### 1. 밑에 과정은 [devstack installtion guide](https://github.com/hyunchan-park/jcloud/blob/main/InstallationGuide.md) 참고하여 설치 하였다 

### 2. docker 설치
2-1. 필수 패키지 설치
```
sudo apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common
```
2-2. GPG Key 인증
```
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
```
2-3. docker repository 등록
```
sudo add-apt-repository \
"deb [arch=amd64] https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) \
stable"
```
2-4. apt docker 설치
```
sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io
```
2-5. docker 설치 확인
```
service docker status
```
### 3. prometheus 설치
3-1. 설치 파일 다운로드
```
wget https://github.com/prometheus/prometheus/releases/download/v2.32.0-rc.0/prometheus-2.32.0-rc.0.linux-amd64.tar.gz
tar xzvf prometheus-2.32.0-rc.0.linux-amd64.tar.gz
mv prometheus-2.32.0-rc.0.linux-amd64 prometheus
```
3-2. prometheus.yml 수정 (형식에 맞게 마지막 부분에 추가)
```
- job_name: 'openstack'
    openstack_sd_configs:
      - role: 'instance'
        identity_endpoint: 'http://본인 dashboard ip/identity/v3'
        username: 'admin'
        project_name: 'admin'
        password: '본인 password'
        region: 'RegionOne'
        domain_name: 'default'
        port: 9100
    relabel_configs:
      - source_labels: [__meta_openstack_public_ip]
        target_label: __address__
        replacement: '$1:9100'
```
3-3. 서비스 등록
```
cd /etc/systemd/system
vi prometheus.service
```
아래 내용 복사 후 붙여넣기
```
[Unit]
Description=Prometheus Server
Documentation=https://prometheus.io/docs/introduction/overview/
After=network-online.target

[Service]
User=stack
Restart=on-failure

ExecStart=/opt/stack/prometheus/prometheus \
  --config.file=/opt/stack/prometheus/prometheus.yml \
  --storage.tsdb.path=/opt/stack/prometheus/data

[Install]
WantedBy=multi-user.target
```
서비스 등록 및 시작
```
systemctl daemon-reload
systemctl start prometheus
systemctl enable prometheus
```
3-4 http://localhost:9090 으로 접속하여 확인
![prometheus_dashboard](https://user-images.githubusercontent.com/91930210/144958941-48b73d8b-23e8-4519-a9ae-ab24663d3dbf.PNG)

