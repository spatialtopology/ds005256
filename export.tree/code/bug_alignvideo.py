import os
import glob

# Base directory
topdir = "/Users/h/Documents/projects_local/1076_spacetop"

# Pattern to match the files
filepattern = "sub-*_ses-*_task-alignvideos_acq-mb8_run-*_events.tsv"

# Walk through the directory structure
for dirpath, dirnames, filenames in os.walk(topdir):
    if "func" in dirpath.split(os.sep) and all(x in dirpath for x in ["sub-", "ses-"]):
        # Find all files matching the pattern
        for filename in glob.glob(os.path.join(dirpath, filepattern)):
            # Construct full file path
            filepath = os.path.join(dirpath, filename)
            # Delete the file
            os.remove(filepath)
            print(f"Deleted: {filepath}")
