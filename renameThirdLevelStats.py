import os
import shutil
import re

def copy_3rd_level_files_to_new_names(root_dir="."):
    path = f"/media/user/Data/fmri-data/analysis-output/third-level-results"
    root_dir = path
    pattern = "(.*).gfeat"
    for root, dirs, files in os.walk(root_dir):
        if re.search("gfeat", root):
                    matches = re.search(pattern, root)
                    condition = matches[1]
        for filename in files:
            if filename == 'tstat1.nii.gz':
                new_filename = f"{condition}.nii.gz"
                new_file_path = os.path.join(root, new_filename)
                shutil.copy(os.path.join(root, filename), new_file_path)
                # print({root})
                # print(new_file_path)

if __name__ == "__main__":
    copy_3rd_level_files_to_new_names()
