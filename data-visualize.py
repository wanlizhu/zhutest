#!/bin/python3
import sys 
import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.gridspec import GridSpec


def main():
    if len(sys.argv) < 2:
        print("Error: csv file path is missing")
        sys.exit(1)

    try:
        # Read and clean data
        df = pd.read_csv(sys.argv[1])
        original_columns = [col.strip() for col in df.columns.to_list()]
        df = df.replace('[^\d.]', '', regex=True).astype(float)
        df.columns = [col.strip().replace(' ', '_') for col in original_columns]
        ranges = df.max() - df.min()
        ranges[ranges == 0] = 1e-9
        normalized_df = (df - df.min()) / ranges
        stats = df.agg(['min', 'max', 'mean', 'std']).T.round(2)
        stats.index = original_columns # Use original names for display

        # Create figure
        fig = plt.figure(figsize=(16, 12))
        gs = GridSpec(2, 1, height_ratios=[3, 1], hspace=0.05)
        ax_plot = fig.add_subplot(gs[0])
        ax_stats = fig.add_subplot(gs[1])
        num_cols = len(df.columns)
        colors = plt.cm.tab10(np.linspace(0, 1, num_cols))

        # Plot each column
        x = np.arange(len(df))
        for idx, col in enumerate(normalized_df.columns):
            ax_plot.plot(x, normalized_df[col], 
                         color=colors[idx], 
                         label=original_columns[idx])
        ax_plot.set_title('GPU Utilization Analysis', pad=20)
        ax_plot.set_ylabel('Normalized Value')
        ax_plot.grid(alpha=0.3)
        ax_plot.legend(loc='upper left', bbox_to_anchor=(1.02, 1), borderaxespad=0)

        # Statistics panel
        name_maxlen = 1
        for idx, (col, vals) in enumerate(stats.iterrows()):
            if len(col) > name_maxlen:
                name_maxlen = len(col)
        ax_stats.axis('off')
        y_start = 0.95 
        y_step = 0.12 
        for idx, (col, vals) in enumerate(stats.iterrows()):
            y_pos = y_start - (idx * y_step)
            stats_text = (
                f"{col:>{name_maxlen}} => ["
                f"Min: {vals['min']:>8.2f}, "
                f"Max: {vals['max']:>8.2f}, "
                f"Avg: {vals['mean']:>8.2f}, "
                f"Std: {vals['std']:>8.2f}]"
            )
            ax_stats.text(0.01, y_pos, stats_text, 
                          color=colors[idx], 
                          fontfamily="monospace",
                          fontsize=12,
                          transform=ax_stats.transAxes,
                          verticalalignment='top')
        
        # Show final result 
        plt.subplots_adjust(left=0.08, right=0.78, top=0.92, bottom=0.08, hspace=0.1)
        plt.show()
    except Exception as e:
        print(f"Error: {str(e)}")


if __name__ == "__main__":
    main()
