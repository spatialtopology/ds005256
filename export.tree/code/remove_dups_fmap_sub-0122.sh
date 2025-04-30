#!/bin/bash 
set -eu #exit as soon as error. if undefined variable; spit error

# NEED TO REMOVE PRIMARY and rename DUP as PRIMARY
LOG_FILE="./fmap_sub-0122_logfile.txt"
DUPJSON="./sub-0122/ses-03/fmap/sub-0122_ses-03_acq-mb8_dir-pa_run-01_epi__dup-01.json"
DUPJSON_TR=$(jq '.AcquisitionTime' "${DUPJSON}")
PRIMARYJSON=$(echo "${DUPJSON}" | sed 's/__dup-[0-9]*//')
PRIMARYJSON_TR=$(jq '.AcquisitionTime' "${PRIMARYJSON}")

if [[ "$PRIMARYJSON_TR" == "null" || "$PRIMARYJSON_TR" =~ "error" ]]; then
     echo "$PRIMARYJSON: Error extracting TR value." >> "${LOG_FILE}"
     continue
fi

PRIMARYJSON_NODEC=${PRIMARYJSON_TR%%.*}
DUPJSON_NODEC=${DUPJSON_TR%%.*}
PRIMARYJSON_SEC=$(echo $PRIMARYJSON_NODEC |  tr -d '"'| awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
DUPJSON_SEC=$(echo $DUPJSON_NODEC |  tr -d '"' | awk -F: '{ print ($1 * 3600) + ($2 * 60) + $3 }')
echo "$DUPJSON_SEC"
echo "$PRIMARYJSON_SEC"

if [ "$PRIMARYJSON_SEC" -lt "$DUPJSON_SEC" ]; then
echo -e "\n${DUPJSON}\nPRIMARYJSON acquisition time is earlier." >> "${LOG_FILE}"
	echo "do we get here, line 22?"
     # SWAP DUP AND PRIMARY, THEN DELETED
     DIRPATH=$(dirname "${DUPJSON}")
     PRIMARYGZ="${DIRPATH}/$(basename "${PRIMARYJSON}" .json).nii.gz"
     DUPGZ="${DIRPATH}/$(basename "${DUPJSON}" .json).nii.gz"
     # Identifying corresponding dir-ap file
     APGZ="${DIRPATH}/$(basename "${DUPJSON}" .json | sed 's/_dir-pa_/_dir-ap_/').nii.gz"

     echo "we will swap files: ${PRIMARYGZ} to ${DUPGZ} and deleted ${DUPGZ}"
     # RENAME JSON primary is crap, keep dup_______
     $(dirname "$0")/rename_file "${PRIMARYJSON}" "${DIRPATH}/CRAPJSON.json"
     $(dirname "$0")/rename_file "${DUPJSON}" "${PRIMARYJSON}"
     $(dirname "$0")/rename_file "${DIRPATH}/CRAPJSON.json" "${DUPJSON}"
     # # RENAME fmap______
     $(dirname "$0")/rename_file "${PRIMARYGZ}" "${DIRPATH}/CRAPJSON.nii.gz"
     $(dirname "$0")/rename_file "${DUPGZ}" "${PRIMARYGZ}"
     $(dirname "$0")/rename_file "${DIRPATH}/CRAPJSON.nii.gz" "${DUPGZ}"

     # New renaming for dir-ap file to make it the new duplicate

     # New renaming for dir-ap file to make it the new duplicate
     DUPAPGZ="${DIRPATH}/$(basename "${DUPJSON}" .json | sed 's/_dir-pa_/_dir-ap_/').nii.gz" # mirror image of ap file
     DUPAPJSON="${DIRPATH}/$(basename "${DUPJSON}" | sed 's/_dir-pa_/_dir-ap_/')"
     PRIMARYAPGZ="$(echo "${DUPAPGZ}" | sed 's/__dup-[0-9]*//')"
     PRIMARYAPJSON="${DIRPATH}/$(basename "${PRIMARYAPGZ}" .nii.gz).json"

     $(dirname "$0")/rename_file "${PRIMARYAPJSON}" "${DIRPATH}/CRAPJSON.json"
     $(dirname "$0")/rename_file "${DUPAPJSON}" "${PRIMARYAPJSON}"
     $(dirname "$0")/rename_file "${DIRPATH}/CRAPJSON.json" "${DUPAPJSON}"
     # # RENAME fmap______
     $(dirname "$0")/rename_file "${PRIMARYAPGZ}" "${DIRPATH}/CRAPJSON.nii.gz"
     $(dirname "$0")/rename_file "${DUPAPGZ}" "${PRIMARYAPGZ}"
     $(dirname "$0")/rename_file "${DIRPATH}/CRAPJSON.nii.gz" "${DUPAPGZ}"


     # DELETE files
     generic_filename=$(echo "$DUPJSON" | sed -E 's/(run-[0-9]+_).+(__dup-[0-9]+).*/\1*\2.*/')
     ap_generic_filename=$(echo "${DUPAPJSON}" | sed -E 's/(run-[0-9]+_).+(__dup-[0-9]+).*/\1*\2.*/') # Pattern for the new duplicate dir-ap file



     read -a files_to_remove <<< "$generic_filename $ap_generic_filename"
     
     for rm_file in "${files_to_remove[@]}"; do
     	echo "remove! ${rm_file}"

     	git rm -f "$rm_file"
     done

fi

