#!/bin/bash -x
#	./bin/app-config-deploy.sh
#########################################################################
#      Copyright (C) 2020        Sebastian Francisco Colomar Bauza      #
#      SPDX-License-Identifier:  GPL-2.0-only                           #
#########################################################################
set +x && test "$debug" = true && set -x 				;
#########################################################################
test -n "$branch_app"		|| exit 100				;
test -n "$debug"		|| exit 100				;
test -n "$repository_app"	|| exit 100				;
test -n "$username_app"		|| exit 100				;
#########################################################################
folders=" configs secrets " 						;
umask_new=0077								;
umask_old=$( umask ) 							;
#########################################################################
umask $umask_new							;
uuid=$( uuidgen )							;
git clone --single-branch --branch $branch_app				\
  https://github.com/$username_app/$repository_app /root/$uuid		;
for folder in $folders 							;
do 									\
  cp --recursive --verbose /root/$uuid/run/$folder /run  		;
done 									;
rm --recursive --force /root/$uuid 		 			;
umask $umask_old							;
#########################################################################
