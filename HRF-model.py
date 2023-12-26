import numpy as np
import matplotlib.pyplot as plt
from scipy.stats import gamma
from scipy.signal import convolve


def double_gamma_hrf(tr=2.0, duration=32.0, oversampling=16, onset=0.0):
    # time vector
    dt = tr / oversampling
    time = np.arange(0, duration, dt) - onset

    # parameters for the hrf
    a1, b1 = 6, 1  # parameters for the positive gamma function (peak)
    a2, b2 = 12, 1 # parameters for the negative gamma function (undershoot)
    c = 1 / 6      # scaling factor

    # gamma functions
    g1 = gamma.pdf(time, a1, scale=b1)
    g2 = gamma.pdf(time, a2, scale=b2)

    # combine the two gamma functions to get the hrf
    hrf = g1 - c * g2

    # normalize the hrf
    hrf /= np.max(hrf)

    return time, hrf


# Generate the HRF
time, hrf = double_gamma_hrf()

# Stimulus series
trial_duration = 8  # seconds
display_duration = 20  # seconds
tr = 0.1  # seconds
num_events = 8
stimulus_duration = 2 # TRs

# Generate stimulus series
stimulus1 = np.zeros(int(display_duration / tr))
stimulus2 = np.zeros(int(display_duration / tr))

# Space events equally in the first 5 seconds for stimulus1
events1 = np.linspace(0, 5 / tr, num_events, endpoint=False, dtype=int)
for t in events1:
    stimulus1[t:t+stimulus_duration] = 1

# Space events equally over the entire 8 seconds for stimulus2
events2 = np.linspace(0, 8 / tr, num_events, endpoint=False, dtype=int)
for t in events2:
    stimulus2[t:t+stimulus_duration] = 1

# Convolve the stimulus series with the HRF
convolved1 = convolve(stimulus1, hrf, mode='full')[:len(stimulus1)]
convolved2 = convolve(stimulus2, hrf, mode='full')[:len(stimulus2)]

# Time parameters for extended plot
time_vector = np.arange(0, display_duration, tr)

# Extend the convolved responses for plotting
extended_convolved1 = np.pad(convolved1, (0, len(time_vector) - len(convolved1)), mode='constant')
extended_convolved2 = np.pad(convolved2, (0, len(time_vector) - len(convolved2)), mode='constant')

# Extend the stimulus series for plotting
extended_stimulus1 = np.pad(stimulus1, (0, len(time_vector) - len(stimulus1)), mode='constant')
extended_stimulus2 = np.pad(stimulus2, (0, len(time_vector) - len(stimulus2)), mode='constant')

import pandas as pd
import seaborn as sns

# Create dataframes for the plots
df1 = pd.DataFrame({
    'Time (s)': time_vector,
    'Response': extended_convolved1,
    'Series': 'HRF Convolved with Stimulus 1'
})
df1_stimulus = pd.DataFrame({
    'Time (s)': time_vector,
    'Response': extended_stimulus1,
    'Series': 'Stimulus Series 1'
})

df2 = pd.DataFrame({
    'Time (s)': time_vector,
    'Response': extended_convolved2,
    'Series': 'HRF Convolved with Stimulus 2'
})
df2_stimulus = pd.DataFrame({
    'Time (s)': time_vector,
    'Response': extended_stimulus2,
    'Series': 'Stimulus Series 2'
})

# Combine data for plotting
df_combined1 = pd.concat([df1, df1_stimulus])
df_combined2 = pd.concat([df2, df2_stimulus])

# Set the figure size
plt.figure(figsize=(12, 8))

# Plot for Stimulus Series 1
plt.subplot(2, 1, 1)
sns.lineplot(x='Time (s)', y='Response', hue='Series', style='Series', data=df_combined1, markers=False)
plt.title('HRF Convolved with Stimulus Series 1')
plt.ylim(-1, 12)  # Adjust y-axis limits for better visualization

# Plot for Stimulus Series 2
plt.subplot(2, 1, 2)
sns.lineplot(x='Time (s)', y='Response', hue='Series', style='Series', data=df_combined2, markers=False)
plt.title('HRF Convolved with Stimulus Series 2')
plt.ylim(-1, 12)  # Adjust y-axis limits for better visualization

plt.tight_layout()
plt.show()




# # plotting
# plt.figure(figsize=(12, 8))

# # plot for stimulus series 1
# plt.subplot(2, 1, 1)
# plt.plot(time_vector, extended_stimulus1, label='stimulus series 1', linestyle='--', alpha=0.7)
# plt.plot(time_vector, extended_convolved1, label='hrf convolved with stimulus 1')
# plt.xlabel('time (s)')
# plt.ylabel('response')
# plt.title('hrf convolved with stimulus series 1')
# plt.legend()
# plt.ylim(-1, 12)  # adjust y-axis limits for better visualization

# # plot for stimulus series 2
# plt.subplot(2, 1, 2)
# plt.plot(time_vector, extended_stimulus2, label='stimulus series 2', linestyle='--', alpha=0.7)
# plt.plot(time_vector, extended_convolved2, label='hrf convolved with stimulus 2')
# plt.xlabel('time (s)')
# plt.ylabel('response')
# plt.title('hrf convolved with stimulus series 2')
# plt.legend()
# plt.ylim(-1, 12)  # adjust y-axis limits for better visualization

# plt.tight_layout()
# plt.show()
