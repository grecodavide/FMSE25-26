import matplotlib.pyplot as plt

property = "level"
simu = f"static_{property}"
filename = f'{simu}_simulation.csv'
simulations = {}
current_sim = None

# 1. Read and parse the custom file
with open(filename, 'r') as f:
    for line in f:
        line = line.strip()
        if not line or line.startswith('####'):
            continue  # Skip empty lines and the main header

        # Detect a new simulation block (e.g., "# frogger.level #1")
        if line.startswith('#'):
            current_sim = line.strip('# ').strip()
            simulations[current_sim] = {'x': [], 'y': []}
        # Read the numerical data
        elif current_sim:
            parts = line.split(',')
            if len(parts) >= 2:
                try:
                    simulations[current_sim]['x'].append(float(parts[0]))
                    simulations[current_sim]['y'].append(float(parts[1]))
                except ValueError:
                    pass # Ignore lines that aren't valid numbers

# 2. Plot the data
plt.figure(figsize=(10, 6))

for sim_name, data in simulations.items():
    name = sim_name.replace(f"frogger.{property}", "simulation")
    name = name.replace("#", "")
    plt.plot(data['x'], data['y'], label=name)

# 3. Formatting and Legend
plt.xlabel('time units')
plt.ylabel(property)
plt.title('Simulation Results')
# plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left') # Moves legend outside the plot
plt.tight_layout()
plt.savefig(f"../assets/{simu}_simulation.png")
