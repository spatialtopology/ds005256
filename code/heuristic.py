# Provide mapping into reproin heuristic names

from heudiconv.heuristics import reproin

from heudiconv.heuristics.reproin import *

POPULATE_INTENDED_FOR_OPTS = {
    'matching_parameters': ['ImagingVolume', 'Shims'],
    'criterion': 'Closest'
}

protocols2fix.update({
    '':  # for any study given.  Needs recent heudiconv
        [
            # All those come untested and correspond to some older pilot runs
            # regular expression, what to replace with
            ('AAHead_Scout_.*', 'anat-scout'),
            ('^dti_.*', 'dwi'),
            ('^space_top_distortion_corr.*_([ap]+)_([12])', r'fmap-epi_dir-\1_run-\2'),
            # I do not think there is a point in keeping any
            # of _ap _32ch _mb8 in the output filename, although
            # could be brought into _acq- if very much desired OR
            # there are some subjects/sessions scanned differently
            ('^(.+)_ap.*_r(0[0-9])', r'func_task-\1_run-\2'),
            # also the same as above...
            ('^t1w_.*', 'anat-T1w'),
            # below are my guesses based on what I saw in README
            ('_r(0[0-9])', r'_run-\1'),
            ('self_other', 'selfother'),

            # For more recent runs:
            # pepolar for DWI -- upper cased, so let's just do manually for each
            # Added  _acq-96dir-6b0-mb  so matches the one in DWI
            ('dwi_acq-discorr-PA', r'fmap-epi_dir-pa_acq-96dir-6b0-mb'),
            ('dwi_acq-discorr-AP', r'fmap-epi_dir-ap_acq-96dir-6b0-mb'),
            # pepolar for fMRI
            # problematic case -- multiple identically named pepolar fieldmap runs
            # I guess we will just sacrifice ability to detect canceled runs here.
            # And we cannot just use _run+ since it would increment indepdently
            # for ap and then for pa.  We will rely on having ap preceding pa.
            # Added  _acq-mb8  so they match the one in funcs
            ('func_task-discorr_acq-ap', r'fmap-epi_dir-ap_acq-mb8_run+'),
            ('func_task-discorr_acq-pa', r'fmap-epi_dir-pa_acq-mb8_run='),
            # but removing -ap in funcs so we do not introduce non-matching _acq
            ('_acq-ap-mb8', '_acq-mb8'),

# UNRELATED to spacetop @ dbic
#            # For  a2dtn01  on tacc -- based on the wrong field
#            #('^ssfse', 'anat-scout'),
#            #('^research/ABCD/mprage_promo', 'anat-T1w'),
#            #('^research/ABCD/muxepi2', 'dwi'),
#            #('^research/ABCD/epi_pepolar', 'fmap-epi_run-1'),  
#            #('^research/ABCD/muxepi$', 'func_task-unk_run-unk'), 
#            ('^3Plane_Loc.*', 'anat-scout'),
#            ('^T1_MPRAGE', 'anat-T1w'),
#            ('^DWI', 'dwi'),
#            ('^GE_EPI_B0_(AP|PA)', r'fmap-epi_acq-GE_dir-\1'),
#            ('^GE_EPI_B0', 'fmap-epi_acq-GE'),  
#            ('^SE_EPI_B0_(AP|PA)', r'fmap-epi_dir-\1'),
#            ('^SE_EPI_B0', 'fmap-epi'),  
#            ('^REST([12])$', r'func_task-rest_run-\1'), 
#            ('^CUFF([12])$', r'func_task-cuff_run-\1'), 
        ],
})

# We need to overload to be able to feed scans from varying
# accessions as for ses02 tasks being scanned in ses04.
# Fix to reproin sent in https://github.com/nipy/heudiconv/pull/508
def fix_canceled_runs(seqinfo):
    return seqinfo
reproin.fix_canceled_runs = fix_canceled_runs
