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
        df = df.replace('[^\d.]', '', regex=True).astype(float)
        original_columns = df.columns.to_list()
        cleaned_columns = [col.strip().replace(' ', '_') for col in original_columns]

        print("Available columns:")
        for idx, col in enumerate(original_columns):
            print(f"{idx}: {col}")
        plot_all = input("Do you want to plot all columns? (y/n): ").strip().lower()
        if plot_all == 'y':
            original_columns_to_plot = original_columns
            cleaned_columns_to_plot = cleaned_columns
        else:
            selected_indices = input("Enter the indices of the columns to plot (comma-separated): ").strip().lower().split(',')
            original_columns_to_plot = [original_columns[int(idx)] for idx in selected_indices]
            cleaned_columns_to_plot = [cleaned_columns[int(idx)] for idx in selected_indices]

        df = df[original_columns_to_plot] 
        df.columns = cleaned_columns_to_plot
        original_columns_to_plot = [col.strip() for col in original_columns_to_plot]

        ranges = df.max() - df.min()
        ranges[ranges == 0] = 1e-9
        normalized_df = (df - df.min()) / ranges
        stats = df.agg(['min', 'max', 'mean', 'std']).T.round(2)

        # Create figure
        fig = plt.figure(figsize=(16, 12))
        gs = GridSpec(2, 1, height_ratios=[3, 1], hspace=0.05)
        ax_plot = fig.add_subplot(gs[0])
        ax_stats = fig.add_subplot(gs[1])
        colors = plt.cm.tab10(np.linspace(0, 1, len(df.columns)))

        # Plot each column
        x = np.arange(len(df))
        for idx, col in enumerate(df.columns):
            ax_plot.plot(x, normalized_df[col], 
                         color=colors[idx], 
                         linewidth=1.5,
                         label=original_columns_to_plot[idx])
        ax_plot.set_title('GPU Utilization Analysis', pad=20, fontsize=14)
        ax_plot.set_ylabel('Normalized Value', fontsize=12)
        ax_plot.tick_params(axis='both', labelsize=10)
        ax_plot.grid(alpha=0.3)
        leg = ax_plot.legend(loc='upper left', 
                             bbox_to_anchor=(1.02, 1), 
                             fontsize=10, 
                             borderaxespad=0.9)
        leg.set_title("Metrics", prop={'size': 12})

        # Statistics panel
        name_maxlen = max(len(col) for col in original_columns_to_plot)
        ax_stats.axis('off')
        y_start = 0.95 
        y_step = 0.12 
        for idx, (col, vals) in enumerate(stats.iterrows()):
            y_pos = y_start - (idx * y_step)
            stats_text = (
                f"{original_columns_to_plot[idx]:>{name_maxlen}} => ["
                f"Min: {vals['min']:>8.2f} | "
                f"Max: {vals['max']:>8.2f} | "
                f"Avg: {vals['mean']:>8.2f} | "
                f"Std: {vals['std']:>8.2f}]"
            )
            ax_stats.text(0.01, y_pos, stats_text, 
                          color=colors[idx], 
                          fontfamily="monospace",
                          fontsize=12,
                          transform=ax_stats.transAxes,
                          verticalalignment='top',
                          bbox=dict(facecolor='white', alpha=0.7, edgecolor='none', pad=3.0))
        
        # Show final result 
        plt.subplots_adjust(left=0.08, right=0.78, top=0.92, bottom=0.08, hspace=0.1)
        plt.show()
    except Exception as e:
        print(f"Error: {str(e)}")


if __name__ == "__main__":
    main()
