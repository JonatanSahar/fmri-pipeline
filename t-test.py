#!/usr/bin/python3
import sys
import numpy as np
from scipy import stats
if len(sys.argv) != 2:
    print("Please provide one file path as argument.")
    sys.exit(1)

# Read file paths from command line arguments
file_path = sys.argv[1]

# Load data from files
data = np.loadtxt(file_path)

# Perform t-test
t_stat, p_val = stats.ttest_1samp(data, popmean=0, alternative="two-sided")

print(f'T-statistic: {t_stat}')
print(f'P-value: {p_val}')

