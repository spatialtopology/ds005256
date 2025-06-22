#!/bin/bash

set -eu

for d in tomsaxe tomspunt memory; do 
    old_name=task-$d/
    new_name=task-fractional/runtype-$d/; 
    git mv "stimuli/$old_name" "stimuli/$new_name"
    git grep -l "task-$d/" '**/*events.tsv' | xargs sed -i'' -e "s,$old_name,$new_name,g"
done
