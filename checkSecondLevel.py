#!/usr/bin/python3
from aux import *

if __name__ == '__main__':
    sub_id = input('Enter subject number: ')
    path = f"/media/user/Data/fmri-data/analysis-output/{sub_id}/"
    copy_2nd_level_files_to_new_names(path=path)
    loadFilesToFslEyes(second_level=True, path=path)
