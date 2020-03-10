def check_repeated_edge(edges, new_edge):
	n_edges = len(edges)
	for i in range(n_edges):
		old_edge = edges[i]
		if(old_edge[0] == new_edge[0] and old_edge[1] == new_edge[1]):
			return -i
		if (old_edge[0] == new_edge[1] and old_edge[1] == new_edge[0]):
			return -i
	return n_edges

file_in = open('mesh.msh','r')
file_ou = open('mesh.fmsh','w+')



for line in file_in:
	data = line.split()
	data[2] = '2'
	elem_type = data[4]
	file_ou.write(' '.join(data))
	break

if elem_type == 'Triangle':
	corner_nodes = 3
elif elem_type == 'Quad':
	corner_nodes = 4

file_ou.write('\n\n')

for line in file_in:
	file_ou.write(line)
	if(line == 'End Coordinates\n'):
		break

for line in file_in:
	if(line == 'Elements\n'):
		break
	file_ou.write(line)
		
elements = []
edges = []

file_ou.write('Elements-nodes\n')

for line in file_in:
		if(line == 'End Elements\n'):
			break
		file_ou.write(line)
		
		data = line.split()
		n_data = len(data)
		new_element = []
		for i in range(1,corner_nodes):
			j = (i + 1) if (i+1<n_data) else (1)
			new_edge = []
			new_edge.append(int(data[i]))
			new_edge.append(int(data[j]))
			new_id = check_repeated_edge(edges, new_edge)
			
			if new_id >= 0: # Edge is new
				edges.append(new_edge)
				new_element.append(new_id)
			else: # Edge is repeated
				new_element.append(-new_id)
		elements.append(new_element)
file_ou.write('End Elements-nodes\n\n')
		
file_ou.write('Edges\n')
for i in range(len(edges)):
	file_ou.write(' %3d %3d %3d\n'%(i+1, edges[i][0], edges[i][1]))
file_ou.write('End Edges\n')
file_ou.write('\n')
file_ou.write('Elements-edges\n')
for i in range(len(elements)):
	outp = ' %3d'%(i+1)
	for j in range(len(elements[i])):
		outp +=  ' %3d'%(elements[i][j] + 1)
	file_ou.write(outp + '\n')
file_ou.write('End Elements-edges\n')
	
file_in.close()
file_ou.close()

print('GiD file transformed successfully')