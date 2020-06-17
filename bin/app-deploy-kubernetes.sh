#!/bin/bash -x
#	./bin/app-deploy-kubernetes.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set +x && test "$debug" = true && set -x 				;
#########################################################################
test -n "$apps"			|| exit 100				;
test -n "$branch_app"   	|| exit 100                             ;
test -n "$debug"        	|| exit 100                             ;
test -n "$domain"       	|| exit 100                             ;
test -n "$repository_app"	|| exit 100				;
test -n "$username_app"		|| exit 100				;
#########################################################################
apps="                                                                  \
  $(                                                                    \
    echo                                                                \
      $apps                                                             \
    |                                                                   \
      base64                                                            \
        --decode                                                        \
  )                                                                     \
"                                                                       ;
kubeconfig=/etc/kubernetes/admin.conf 					;
path=$username_app/$repository_app/$branch_app/etc/docker/$mode		;
#########################################################################
for config in $( find /run/configs -type f )				;
do									\
  file=$( basename $config )						;
  kubectl create configmap $file 					\
    --from-file $config 						\
    --kubeconfig $kubeconfig						\
									; 
  rm --force $config							; 
done									;
#########################################################################
for secret in $( find /run/secrets -type f )				;
do									\
  file=$( basename $secret )						;
  kubectl create secret generic $file 					\
    --from-file $secret 						\
    --kubeconfig $kubeconfig						\
									;
  rm --force $secret							; 
done									;
#########################################################################
for app in $apps							;
do 									\
  prefix=$( echo $app | cut --delimiter . --field 1 )			;
  suffix=$( echo $app | cut --delimiter . --field 2 )			;
  for name in $prefix							;
  do									\
    uuid=$( uuidgen )							;
    curl --output $uuid https://$domain/$path/$name.$suffix?$( uuidgen );
    kubectl apply --filename $uuid --kubeconfig $kubeconfig		;
    rm --force $uuid							;
  done									;
done									;
#########################################################################
kubectl get node							;
kubectl get service							;
kubectl get pod								;
#########################################################################
