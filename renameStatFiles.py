import os
import shutil

def copy_files_to_new_names(root_dir="."):
    for root, dirs, files in os.walk(root_dir):
        for filename in files:
                condition = root.split('_')[1]
                run_num = root.split('_')[2].split('.')[0]
            if filename == 'tstat1.nii.gz':
                new_filename = f"{condition}_R_over_L_{run_num}.nii.gz"
                new_file_path = os.path.join(root, new_filename)
                shutil.copy(os.path.join(root, filename), new_file_path)
            elif filename == 'tstat2.nii.gz':
                new_filename = f"{condition}_L_over_R_{run_num}.nii.gz"
                new_file_path = os.path.join(root, new_filename)
                shutil.copy(os.path.join(root, filename), new_file_path)
