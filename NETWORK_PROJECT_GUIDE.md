# Two Network Systems 3 projects (2025)

## 1. Software-Defined Virtual Network
Open `projects/sdn-network.html`. Uses original report evidence extracted from the user-provided GA1 document:
- `assets/gns3-topology.webp`
- `assets/sdn-python-monitor.webp`
- `assets/gns3-traceroute.webp`
- `assets/gns3-ping-tests.webp`

No GNS3 installation or original GNS3 project file is required to view the evidence. Original network images are archived screenshots and cannot be edited as simulations.

## 2. Traffic Engineering using Graph Theory and Linear Programming
Open `projects/traffic-engineering.html`, then `network-demo/index.html`. The **interactive shortest-path browser demo** is rebuilt from the supplied CSV. The demonstration is not historical proof of the complete 2025 linear programming solution.

- `network-code/GEANT2_Links.csv` – preserved user-supplied dataset
- `network-code/shortest_path_demo.py` – transparent Python recreation (NetworkX + Matplotlib)
- `network-demo/routes.js` – self-contained Dijkstra visualisation

Data audit: supplied CSV includes 32 nodes and 55 unique undirected edges; project brief says 54 links. Archived report contains conflicting numerical results; do not treat these as independently verified. The CSV weighted shortest route 32 to 1 is direct with cost 5.

## Install the update
Copy the ZIP contents into your existing GitHub repository folder `MphoentleK`, **keeping** its `.git` directory. Replace matching files, then open `index.html` and click the project cards. Commit and push through GitHub Desktop when satisfied.

## Privacy and provenance
The portfolio does not publish academic reports containing private student numbers or instructor-produced brief templates. Historical SDN images come from the user's submitted report; shortest-path graphics and code in the demo are new reconstructions.
