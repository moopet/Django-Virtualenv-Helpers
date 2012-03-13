#!/bin/bash

LOGFILE="/var/log/manage_wrapper.log"

ENV=$1
shift
CMD=$@

source /usr/local/bin/virtualenvwrapper.sh 
workon $ENV

echo "$ENV: BEGIN $CMD" >> $LOGFILE

OUTPUT=$(nice python manage.py $CMD)

if [ $? != 0 ]; then
    echo $OUTPUT >> $LOGFILE
fi

echo "$ENV: END   $CMD" >> $LOGFILE
