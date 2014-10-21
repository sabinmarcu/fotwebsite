#!/bin/bash

BASE="https://code.angularjs.org"
ITEMS="angular angular-route angular-animate"

for item in $ITEMS; do
    if [ ! -e $3 ]; then
        item="$item.min"
    fi
    item="$item.js"
    url="$BASE/$1/$item"
    item=`echo $item | sed 's/-/\./'`
    echo "Grabbing $url into $item"
    curl $url > $item
done

item="master"
if [ ! -e $2 ]; then 
    item=$2
fi

BASE="https://raw.githubusercontent.com/angular/bower-material/$item/angular-material"
if [ ! -e $3 ]; then 
    BASE="$BASE.min"
fi
BASE="$BASE.js"

echo "Grabbing latest angular-material : $BASE"
curl $BASE > angular.material.js
