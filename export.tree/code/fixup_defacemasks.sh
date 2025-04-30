#!/bin/bash

for f in sub*/ses*/anat/*_T1w_defacemask*; do code/rename_file "$f" "${f//_T1w/_mod-T1w}";done
