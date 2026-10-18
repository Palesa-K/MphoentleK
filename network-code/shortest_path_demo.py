"""Recreated portfolio visualisation from the supplied GEANT2_Links.csv.

Requires: pip install networkx matplotlib
Run from this directory: python shortest_path_demo.py
Note: This re-creates analysis in 2026, not original 2025 solver output.
"""
import csv
from pathlib import Path
import networkx as nx
import matplotlib.pyplot as plt

file = Path(__file__).with_name("GEANT2_Links.csv")
graph = nx.Graph()
with file.open(newline="", encoding="utf-8-sig") as f:
    for row in csv.DictReader(f):
        graph.add_edge(
            int(row["Source"]), int(row["Destination"]),
            weight=int(row["Weight"]), capacity_mbps=int(row["Capacity_Mbps"]),
        )

source, destination = 32, 1
route = nx.shortest_path(graph, source, destination, weight="weight")
cost = nx.shortest_path_length(graph, source, destination, weight="weight")
print(f"Nodes: {graph.number_of_nodes()} | Unique links: {graph.number_of_edges()}")
print(f"Minimum-cost route: {route} | Total link weight: {cost}")
print("Dataset note: the uploaded CSV contains 55 undirected links;")
print("the 2025 project brief describes a 54-link GEANT2 example.")

positions = nx.circular_layout(graph)
selected_edges = list(zip(route[:-1],route[1:]))
plt.figure(figsize=(11,9))
nx.draw_networkx_edges(graph, positions, width=0.8, alpha=0.35, edge_color="#83988a")
nx.draw_networkx_edges(graph, positions, edgelist=selected_edges,
                       width=3.3,edge_color="#15803d")
nx.draw_networkx_nodes(graph, positions, node_size=380,node_color="#e9f8eb",
                       edgecolors="#176141",linewidths=1.3)
nx.draw_networkx_labels(graph, positions, font_size=8,font_weight="bold")
plt.title("GEANT2 topology – minimum-weight route (recreated from supplied CSV)")
plt.axis("off")
plt.tight_layout()
plt.savefig(file.with_name("recreated_shortest_path.png"),dpi=160)
print("Saved: recreated_shortest_path.png")
