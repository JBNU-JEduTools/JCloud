# JCloud monitoring project

## 논문
[오픈스택 환경에서의 실시간 오픈소스 모니터링 시스템 비교분석](https://github.com/tlstmdck/jcloud/blob/main/%EC%98%A4%ED%94%88%EC%8A%A4%ED%83%9D%20%ED%99%98%EA%B2%BD%EC%97%90%EC%84%9C%EC%9D%98%20%EC%8B%A4%EC%8B%9C%EA%B0%84%20%EC%98%A4%ED%94%88%EC%86%8C%EC%8A%A4%20%EB%AA%A8%EB%8B%88%ED%84%B0%EB%A7%81%20%EC%8B%9C%EC%8A%A4%ED%85%9C%20%EB%B9%84%EA%B5%90%EB%B6%84%EC%84%9D.pdf)
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
### dashboards && notification
![image](https://user-images.githubusercontent.com/91930210/145019139-c9c3e4ed-ddfb-4709-b5ef-a20a90f3952a.png)
### 장점
- service 단위로 측정하기 때문에 인스턴스를 접근할 필요가 없이 compute node에서 정보를 가져온다
- alarm설정이 쉽게 구현되어있음
### 단점
- 설치가 매우매우 어려움 (devstack 이 아닌 openstack에서의 설치)

## 결론
- 현재 Jcloud 상황에서는 학생들의 instance를 접근하기 부담스러우므로 service단위로 데이터를 수집하는 monasca가 더 적합해보임
- 그러나 Jcloud에 monasca를 설치하기란 매우 어렵고 오래걸리기 때문에 사용자들이 사용을 안하는 방학기간에 맞춰서 진행하는것이 적합해보임
## demo 버전
- prometheus: http://203.254.143.231:9090 (ID: admin / PW: openstack)
- prometheus + grafana: http://203.254.143.231:3000 (ID: admin / PW: openstack)
- monasca: http://203.254.143.137 (ID: admin / PW: openstack)
  
  현재는 내부망으로만 접속가능
