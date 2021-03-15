#!/usr/bin/python

import seaborn as sns
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import sys

input_file_csv = sys.argv[1]
app_table_csv = sys.argv[2]


input_file = input_file_csv.replace('.csv', '')
plt.figure(figsize=(10,6))

profile_data = pd.read_csv(input_file_csv)
sns_plot = sns.barplot(data=profile_data, x="App", y="Slowdown", hue="BW")

plt.legend(loc='center left', bbox_to_anchor=(1, 0.5), title="% BW")
fig = sns_plot.get_figure()
fig.savefig(input_file + "_all_bars.png")

app_data = pd.read_csv(app_table_csv)

for i in range(10, 100, 10):
    plt.figure(figsize=(10,6))
    is_profile_data_10 = profile_data['BW'] == i
    profile_data_10 = profile_data[is_profile_data_10].filter(items=['App', 'Slowdown'])
    #print('----- App Data -----')
    #print(app_data)
    #print('------ Profile Data 10% ----')
    #print(profile_data_10)

    corr = app_data.set_index('App').join(other=profile_data_10.set_index('App'))
    #print('------- Full Corr -----')
    #print(corr)
    corr = corr.filter(items=['Communication', 'Computation', 'Slowdown']).reset_index().pivot(index='Computation', columns='Communication', values='Slowdown').sort_index(ascending=False)
    #print('------Filter Corr ------')
    #print(corr)
    sns_plot = sns.heatmap(corr, annot = True, fmt='.2g', vmin=1, vmax=10, center= 0)
    fig = sns_plot.get_figure()
    fig.savefig(input_file + "_heatmap_{}.png".format(i))