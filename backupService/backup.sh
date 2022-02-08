#!/usr/bin/env bash
#
# Jcloud의 cse-students 프로젝트들의 스냅샷을 백업서버에 전송한다.

export $(grep -v '^#' .env | xargs)

# 권한 얻기
source $PATH_TO_OPENRC_FILE $ACCOUNT_NAME $PROJECT_NAME

# 시작시간 기록
start_time=$(($(date +%s)))

# jobqueue 없으면 만들어준다.
if [ ! -e $PATH_TO_JOBLIST ]; then
  touch $PATH_TO_JOBLIST
fi

# 백업할 인스턴스 id 업데이트
if [[ -z $(cat $PATH_TO_JOBLIST) ]]; then
  openstack server list -c "ID" | grep "[a-z0-9]" | sed 's/|\| //g' >> \
    $PATH_TO_JOBLIST
fi

while [[ -n $(cat $PATH_TO_JOBLIST) ]]; do
  # 백업할 인스턴스 id
  instance_id=$(head -n 1 $PATH_TO_JOBLIST)
  # 인스턴스 스냅샷을 만드는 시간기록
  timestamp=$(date +%s)
  # 스냅샷 이름
  snapshot_name="snapshot__${PROJECT_NAME}/${instance_id}__${timestamp}"
  # 스냅샷을 만든다.
  test=$(openstack server image create --name $snapshot_name $instance_id)
  # 해당 인스턴스의 스냅샷 정보(ID, Name)을 가져온다.
  snapshots_info=($(openstack image list -c "ID" -c "Name" |
    grep $instance_id | sed 's/ //g'))
  #정책에 따라 백업 대상 스냅샷을 선택한다. 최근 한개의 인스턴스는 유지 시킨다.
  if [ ${#snapshots_info[@]} -gt 1 ]; then
    # 백업할 스냅샷을 선택하고 정보를 분리한다.
    snapshot_info=${snapshots_info[0]}
    snapshot_id=$(echo $snapshot_info | awk -F '|' '{print $2}')
    # TODO (컴퓨터공학부 201716357 권기남)
    # project name에 '__' 이 포함되면 스냅샷이 생성된 시간을 못 가져온다.
    # project name에 관계없이 스냅샷이 생성된 시간을 가져울 수 있도록 개선 필요 합니다.
    timestamp=$(echo $snapshot_info | awk -F '__' '{print $3}' | sed 's/|//g')
    # 스냅샷 파일이 저장 될 때 까지 기다림
    while [ ! -f $PATH_TO_SNAPSHOT_DIR/$snapshot_id ]; do
      sleep 5
    done
    ls -al $PATH_TO_SNAPSHOT_DIR/$snapshot_id
    # 백업 폴더로 이동
    mkdir -p $PATH_TO_SNAPSHOT_WITH_METADATA_DIR/$PROJECT_NAME/$instance_id/
    cp -r $PATH_TO_SNAPSHOT_DIR/$snapshot_id \
      $PATH_TO_SNAPSHOT_WITH_METADATA_DIR/$PROJECT_NAME/$instance_id/"${timestamp}_${snapshot_id}"
    # 백업 서버에 전송 use rsync 네트워크 성능제한 필요
    rsync -zarvh \
      $PATH_TO_SNAPSHOT_WITH_METADATA_DIR \
      $USERNAME_REMOTE@$IPADDRESS_REMOTE:$PATH_TO_SNAPSHOT_BACKUP_DIR_REMOTE \
      --rsh="ssh -p $PORT_REMOTE -i $PATH_TO_PRIVATE_KEY" \
      --bwlimit=$BANDWIDTH_LIMIT \
      --remove-source-files \
      --progress
    # 오래된 백업 삭제, 최신 5개로 유지
    path_to_snapshot_dir=$PATH_TO_SNAPSHOT_BACKUP_DIR/$PROJECT_NAME/$instance_id
    snapshot_list=($(ls $path_to_snapshot_dir))
    length_of_snapshot_list=$((${#snapshot_list[@]}))
    count_of_remove_snapshot=$(($length_of_snapshot_list - $MAX_COUNT_OF_SNAPSHOT))
    for ((i = 0; i < $count_of_remove_snapshot; i++)); do
      rm $path_to_snapshot_dir/${snapshot_list[i]}
    done
    #오픈스택 스냅샷 삭제
    openstack image delete $snapshot_id
  fi
  # 작업 리스트에서 삭제
  sed -i '1d' $PATH_TO_JOBLIST
  # 실행 시간 확인
  current_time=$(($(date +%s)))
  if [[ current_time-start_time -ge $TIMELIMIT ]]; then
    exit 0
  fi
done