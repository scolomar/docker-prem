#	./lib/common-functions.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
function encode_string {						\
  local string="$1"							;
  echo -n $string                                                 	\
  |     	                                                        \
    sed 's/\\/ /'                                           		\
    |                                                       		\
      base64                                          			\
        --wrap 0                                			\
									;
}									;
#########################################################################
function exec_remote_file {						\
  local domain=$1							;
  local file=$2								;
  local path=$3								;
  local uuid=$( uuidgen )						;
  curl --output $uuid https://$domain/$path/$file?$( uuidgen )          ;
  chmod +x ./$uuid                                                      ;
  ./$uuid                                                               ;
  rm --force ./$uuid		                              		;
}									;
#########################################################################
function send_command {							\

  local command="$1" 							;
  local stack=$2 							;
  local target="$3" 							;

  local hostname=${target}						;
  local port=22								;
  local ssh_options="							\
    -o StrictHostKeyChecking=no						\
    -o UserKnownHostsFile=/dev/null					\
  "									;
  local user=root							;

  ssh									\
    ${ssh_options}							\
    -p ${port}								\
    ${user}@${hostname}							\
    ${command}								\
									;

}									;
#########################################################################
function send_list_command {						\
  local command="$1" 							;
  local sleep=$2							;
  local stack=$3 							;
  local target=$4 							;
  local output=$( 							\
    send_command "$command" $stack $target				\
  ) 									;
  while true 								;
  do									\
    echo $output							\
    | 									\
      grep [a-zA-Z0-9] && break 					;
    sleep $sleep							;
  done 									;
}									;
#########################################################################
function send_remote_file {						\
  local domain=$1							;
  local export="$2"							;
  local file=$3								;
  local path=$4								;
  local sleep=$5							;
  local stack=$6							;
  local targets="$7"							;
  local uuid=$( uuidgen )						;
  local command="							\
    $export								\
    &&									\
    curl --output $uuid https://$domain/$path/$file?$( uuidgen )       	\
    &&                                                              	\
    chmod +x $uuid                                              	\
    &&                                                              	\
    ./$uuid                                                       	\
      2>&1                                                    		\
    |                                                               	\
      tee /root/$file.log                                    		\
      &&                                                              	\
      rm --force $uuid							\
  "									;
  for target in $targets                                                ;
  do                                                                    \
    send_list_command "$command" $sleep $stack $target			;
  done                                                                  ;
}									;
#########################################################################
function send_wait_targets {						\
  local command="$1"							;
  local sleep=$2							;
  local stack=$3							;
  local targets="$4"							;
  for target in $targets                                                ;
  do                                                                    \
    send_list_command "$command" $sleep $stack $target			;
  done                                                                  ;
}									;
#########################################################################
function service_wait_targets {						\
  local service=$1							;
  local sleep=$2							;
  local stack=$3							;
  local targets="$4"							;
  command="                                                             \
    service $service status 2> /dev/null | grep running			\
  "                                                                     ;
  send_wait_targets "$command" $sleep $stack "$targets"                 ; 
}									;
#########################################################################
