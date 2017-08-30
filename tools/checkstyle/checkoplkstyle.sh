#!/bin/bash
#
# Check oplk formating style of all files in a commit
#

files=`git diff-tree --no-commit-id --diff-filter=AMCR --name-only --relative -r $GIT_COMMIT | grep -E "\.[h|c]$"`
parameters="-P max-file-length=6000 -P max-line-length=160"

# Filter files and directories which should not be checked
for i in $files; do
    if [[ ! $i =~ ^contrib.* && ! $i =~ ^staging.* && ! $i =~ ^hardware.* && ! $i =~ ^unittests.*  && ! $i =~ .*xap\.h.* ]]; then
        filtered="$filtered $i"
    fi
done

if [[ $filtered != "" ]]; then
    /var/lib/jenkins/.vera++/vera++ --profile oplk $parameters -e -s $filtered
else    
    echo Nothing to be checked!
fi
