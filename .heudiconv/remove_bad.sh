#!/bin/bash

set -eu

thisd=$(dirname $0)
topd=$thisd/..
csv=$thisd/spacetop_subject_id.csv
sidskip=$thisd/sid-skip

git annex unlock "$csv" "$sidskip"
(
export IFS=,
grep 'REMOVE\>' "$csv" \
| while read sub sid acc date ses comment; do
	# do the 
	ssdir="$topd/$sub/$ses"
	hdir="$thisd/${sub#*-}/${ses}"
	# need to reformat the date since year should come first
	date_year=${date##*/}
	date_noyear=${date%/*}
	date2="$date_year/$date_noyear"
	adir=/inbox/DICOM/$date2/$acc/

	for d in $ssdir $hdir $adir; do
		if [ ! -e "$d" ]; then
			echo "ERROR: I expected to find $d for $sub $sid $acc $date $ses $comment"
			exit 1
		fi
	done
	echo "Removing $ssdir and alike"
	rm -rf "$ssdir" "$hdir"
        echo "$adir  # $comment" >> "$sidskip"
	sed -i -e "s/\(^$sub,$sid,$acc.*,REMOVE\>\)/\1D/g" "$csv"
done;
)
git annex add "$csv" "$sidskip"
git commit -m 'Removed some bad sessions as was annotated' -a

