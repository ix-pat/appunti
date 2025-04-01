import matplotlib.pyplot as plt
import networkx as nx
import numpy as np

def generate_permutation_tree(letters):
    G = nx.DiGraph()
    levels = {0: [], 1: [], 2: []}

    # Livello 0
    for i, l in enumerate(letters):
        levels[0].append((l, 0, i))
        G.add_node(l)

    # Livello 1
    for (node0, _, _) in levels[0]:
        for l1 in letters:
            if l1 not in node0:
                node1 = node0 + l1
                levels[1].append((node1, 1, 0))
                G.add_node(node1)
                G.add_edge(node0, node1)

    # Livello 2 (perm. complete)
    for (node1, _, _) in levels[1]:
        for l2 in letters:
            if l2 not in node1:
                node2 = node1 + l2
                levels[2].append((node2, 2, 0))
                G.add_node(node2)
                G.add_edge(node1, node2)

    return G, levels

def generate_fixed_last_level_positions(levels, base_spacing=3.5, expansion_factor=3.0):
    pos = {}
    max_depth = max(levels.keys())

    for depth, nodes in levels.items():
        width = len(levels[depth - 1]) if depth == max_depth else len(nodes)
        spacing = base_spacing + (depth if depth < max_depth else max_depth - 1) * expansion_factor
        y_positions = np.linspace(-width / 2, width / 2, len(nodes)) * spacing

        for (name, x, _), y in zip(nodes, y_positions):
            pos[name] = (x, y)

    return pos

labels = {
    "a": "a",
    "ab": "b",
    "abc": "c",
    "ac": "c",
    "acb": "b",
    "b": "b",
    "ba": "a",
    "bac": "c",
    "bc": "c",
    "bca": "a",
    "c": "c",
    "ca": "a",
    "cab": "b",
    "cb": "b",
    "cba": "a"
}

# Esegui
letters = ['c', 'b', 'a']
G, levels = generate_permutation_tree(letters)
pos = generate_fixed_last_level_positions(levels)

plt.figure(figsize=(10, 12))
nx.draw(
    G, pos, labels=labels, node_size=1000, node_color="lightblue",
    font_size=10, edge_color="gray", arrows=False
)
plt.title("Albero delle permutazioni di 3 lettere (fattoriale di 3)", fontsize=14)
plt.show()
