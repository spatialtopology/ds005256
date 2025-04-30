#!/bin/bash

set -u

grep -v -e BIDS_id -e REMOVED < .heudiconv/spacetop_subject_id.csv | tr ',' ' ' | while read anonsid SID acc date ses com; do 
	pat="${date##*/}/${date%/*}/$acc"; 
	infofile=.heudiconv/${anonsid//sub-/}/$ses/info/filegroup_$ses.json;
	if [ -e "$infofile" ]; then
		accs_converted=$(sed -n -e 's,.*/\(A0[0-9]*\)/.*,\1,gp' "$infofile" | sort | uniq | tr '\n' ' ' | sed -e 's, *$,,g')
		acc_paths_converted=$(sed -n -e 's,.*/\(20../../../A0[0-9]*\)/.*,\1,gp' "$infofile" | sort | uniq | tr '\n' ' ' | sed -e 's, *$,,g')
		if [ "$acc" != "$accs_converted" ]; then
			echo "mismatched for $anonsid $ses: $acc != $accs_converted  which came from $acc_paths_converted"
			grep -e "^$anonsid,$SID,.*,.*,$ses" .heudiconv/spacetop_subject_id.csv | sed -e 's,^,    ,g'
			for acc2 in $accs_converted; do
				if [ "$acc" != "$acc2" ]; then
					grep -e ",$acc2," .heudiconv/spacetop_subject_id.csv | sed -e 's,^,    ,g'
				fi
			done
		elif ! grep -q "$pat" "$infofile" ; then
			echo "mismatched for $anonsid $ses:  pat: '$pat' missing from '$infofile' which has $acc_paths_converted" ;
			grep -e "^$anonsid,$SID,$acc,$date" .heudiconv/spacetop_subject_id.csv | sed -e 's,^,    ,g'
			echo -n "    check locations:"
			for l in $pat $acc_paths_converted; do
				p="/inbox/DICOM/$l"
				[ -e "$p" ] && exists=+ || exists=-
				echo -n " ($exists) $p"
			done
			echo
		fi
	else
		echo "missing '$infofile' for $anonsid $ses" ; 
	fi
done
