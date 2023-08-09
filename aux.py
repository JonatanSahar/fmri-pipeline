import os
import shutil
import subprocess
import re
import pdb
import glob
# pdb.set_trace()

def copy_2nd_level_files_to_new_names(path="."):
    """
    Finds all files with a given name in subdirectories (recursive) whose name matches a given regular expression pattern.

    :param name_pattern: A string representing the name pattern to search for.
    :param dir_pattern: A string representing the regular expression pattern to match directory names.
    :return: A list of file paths.
    """

    # Walk through all directories and subdirectories
    for root, dirs, files in os.walk(path):
        dir_pattern = "(\d+_.*)\.gfeat"
        cope_pattern = "cope([12])"
        file_pattern = "^tstat\d.nii"
        # Check if the directory name matches the given pattern
        matches = re.search(dir_pattern, root)
        if matches:
            # Search for files with the given name in the current directory
            for file in files:
                if re.search(file_pattern, file):
                    cond_str = matches[1].rsplit("_", 1)[0] #remove trailing "_mean"
                    matches = re.search(cope_pattern, root)
                    cope_num = int(matches[1])
                    if cope_num == 1:
                        contrast = "R_over_L"
                    elif cope_num == 2:
                        contrast = "L_over_R"

                    file_path = (os.path.join(root, file))
                    new_filename = f"{cond_str}_mean_{contrast}.nii.gz"
                    new_file_path = (os.path.join(root, new_filename))
                    cmd = (f"cp {file_path} {new_file_path}")
                    subprocess.call(cmd, shell=True)





def copy_first_level_files_to_new_names(path="."):
    pattern = "sub([0-9]+)_([a-zA-Z]+)_([0-9])"
    for root, dirs, files in os.walk(path):
        if not re.search("gfeat", root):
            for filename in files:
                if filename == 'tstat1.nii.gz':
                    matches = re.search(pattern, root)
                    sub_id = matches[1]
                    condition = matches[2]
                    run_num = matches[3]
                    new_filename = f"{sub_id}_{condition}_{run_num}_R_over_L.nii.gz"
                    new_file_path = os.path.join(root, new_filename)
                    shutil.copy(os.path.join(root, filename), new_file_path)
                elif filename == 'tstat2.nii.gz':
                    matches = re.search(pattern, root)
                    sub_id = matches[1]
                    condition = matches[2]
                    run_num = matches[3]
                    new_filename = f"{sub_id}_{condition}_{run_num}_L_over_R.nii.gz"
                    new_file_path = os.path.join(root, new_filename)
                    shutil.copy(os.path.join(root, filename), new_file_path)

def find_files_with_regex(phrase, path='.'):
    for root, dirs, files in os.walk(path):
        for filename in files:
            if re.search(phrase, filename):
                yield os.path.join(root, filename)

def find_anatomy_file(path='.'):
    anatomyName = "brain.nii"
    for root, dirs, files in os.walk(path):
        for filename in files:
            if re.search(anatomyName, filename):
                return os.path.join(root, filename)

def loadFilesToFslEyes(path=".", second_level=False):
    # phrase = input("Enter the phrase to search: ")
    print(path)
    R_over_L_pattern = "[0-9]+_[a-zA-Z]+_[0-9]_R_over_L"
    L_over_R_pattern = "[0-9]+_[a-zA-Z]+_[0-9]_L_over_R"
    anatomyFile = find_anatomy_file(path) + " "
    if second_level:
        R_over_L_pattern = "mean_R_over_L.nii"
        L_over_R_pattern = "mean_L_over_R.nii"
        anatomyFile =  "/home/user/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz "

    file_paths1 = []
    for file_path in find_files_with_regex(R_over_L_pattern, path):
        file_paths1.append(file_path + " -dr 2.8 5 -cm red-yellow ")
        str1 = ' '.join(file_paths1)

    file_paths2 = []
    for file_path in find_files_with_regex(L_over_R_pattern, path):
        file_paths2.append(file_path + " -dr 2.8 5 -cm blue-lightblue ")
        str2 = ' '.join(file_paths2)

    file_paths = file_paths1 + file_paths2
    file_paths = sorted(file_paths)
    str  = ' '.join(file_paths)
    cmd = "fsleyes " + anatomyFile + str

    print(cmd)
    os.system(cmd)

if __name__ == '__main__':
    print("hello!")
    copy_2nd_level_files_to_new_names()




def loadThirdLevelFilesToFslEyes(path="."):
    # phrase = input("Enter the phrase to search: ")
    print(path)
    motor_pattern = "^motor_.*.nii"
    auditory_pattern = "^auditory_.*.nii"
    R_over_pattern = "E_R_over_.*.nii"
    L_over_pattern = "E_L_over_.*.nii"
    R_and_L_over_pattern = "E_R_and_L_over_.*.nii"
    anatomyFile =  "/home/user/fsl/data/standard/MNI152_T1_2mm_brain.nii.gz "

    file_paths = []
    for file_path in find_files_with_regex(motor_pattern, path):
        file_paths.append(file_path + " -dr 2.8 5 -cm pink ")
    for file_path in find_files_with_regex(auditory_pattern, path):
        file_paths.append(file_path + " -dr 2.8 5 -cm brain_colours_bluegray")
    for file_path in find_files_with_regex(R_over_pattern, path):
        file_paths.append(file_path + " -dr 2.8 5 -cm red-yellow ")
    for file_path in find_files_with_regex(L_over_pattern, path):
        file_paths.append(file_path + " -dr 2.8 5 -cm blue-lightblue ")
    for file_path in find_files_with_regex(R_and_L_over_pattern, path):
        file_paths.append(file_path + " -dr 2.8 5 -cm green")

    # file_paths = file_paths1 + file_paths2 + file_paths3 + file_paths4
    # file_paths = sorted(file_paths)
    str  = ' '.join(file_paths)
    cmd = "fsleyes " + anatomyFile + str

    print(cmd)
    os.system(cmd)

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
