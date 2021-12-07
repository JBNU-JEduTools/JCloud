# JCloud monitoring project

## installation
- [prometheus](https://github.com/tlstmdck/jcloud/tree/main/prometheus)
- [monasca](https://github.com/tlstmdck/jcloud/tree/main/monasca)

## prometheus + grafana
### dashboards
- prometheus dashboard: http://localhost:9090
- grafana dashnoard: http://localhost:3000

![grafana](https://user-images.githubusercontent.com/91930210/144961406-ad1e5697-0bb4-4dd8-a6f6-d9e69dac9aa7.PNG)

interval를 통하여 관측 주기를 설정하고 host를 통하여 openstack 내부 인스턴스를 관측할 수 있다.
### notification
![prometheus_notification](https://user-images.githubusercontent.com/91930210/144965230-fa8e8375-d623-4a2e-a150-8eb7c93e8a20.PNG)

prometheus metric을 통하여 값이 일정 범위에 도달하면 지정한 email로 mail을 보내게 된다.

### 장점

- 기존 devstack 위에 prometheus를 간단히 설치 및 수정하여 올리고 grafana 역시 마찬가지로 설치하는 방식이라 설치가 매우 쉬운편이다.
- grafana를 통하여 가시성이 좋은 대쉬보드를 제공 받을 수 있다.

### 단점

- target을 잡는 방식이 각 인스턴스들 내부에 에이전트를 설치하여서 해당 에이전트 가 보낸 메트릭으로 모니터링 하기 때문에
인스턴스를 추가할때마다 에이전트를 설치해야하고 학생들이 주로 쓰는 jcloud 상황에서는 이러한 방식이 적합하지 않아 보인다.
- 단순히 openstack의 서비스 단위가 아닌 컴퓨터 및 서버 한대 한대를 단위로 측정 하기 때문에 openstack위에 있는 서비스들의 부하나 이상 발생시 정확히 무슨 서비스가
문제를 일으키는지 잡아내기 힘들다.

## monasca
### dashboards
### notification
### 장점
### 단점

## demo 버전
- prometheus: http://203.254.143.231:9090 (ID: admin / PW: openstack)
- prometheus + grafana: http://203.254.143.231:3000 (ID: admin / PW: openstack)
- monasca: http://203.254.143.137 (ID: admin / PW: openstack)
  
  현재는 내부망으로만 접속가능
