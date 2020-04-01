def check_repeated_edge(edges, new_edge):
	n_edges = len(edges)
	for i in range(n_edges):
		old_edge = edges[i]
		if(old_edge[0] == new_edge[0] and old_edge[-1] == new_edge[-1]):
			return -i
		if (old_edge[0] == new_edge[-1] and old_edge[-1] == new_edge[0]):
			return -i
	return n_edges+1


import sys

if len(sys.argv)< 2:
    raise Exception('Please input a project name')


project = sys.argv[1]

file_in = open('../data/'+project+'/mesh.msh','r')
file_ou = open('../data/'+project+'/mesh.fmsh','w+')


# Reading setup and re-printing
for line in file_in:
	data = line.split()
	data[2] = '2' # Reducing dymenstion to 2
	elem_type = data[4]
	file_ou.write(' '.join(data))
	break

if elem_type == 'Triangle':
	corner_nodes = 3
elif elem_type == 'Quadrilateral':
	corner_nodes = 4

file_ou.write('\n\n')

# Reading and printing nodes
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
edge_repeated = []

# Writting element-node connectivities
# and obtaining edge-node and element-edge connectivites

file_ou.write('Elements-nodes\n')

for line in file_in:
		if(line == 'End Elements\n'):
			break
		file_ou.write(line)
		
		data = line.split()
		n_data = len(data)
		new_element = []
		for i in range(1,corner_nodes+1):
			j = (i + 1) if (i+1<=corner_nodes) else (1)
			new_edge = []
			new_edge.append(int(data[i]))
			if len(data) > corner_nodes+1 :
				k = i + corner_nodes
				new_edge.append(int(data[k]))
			new_edge.append(int(data[j]))
			new_id = check_repeated_edge(edges, new_edge)
			
			if new_id > 0: # Edge is new
				edges.append(new_edge)
				edge_repeated.append(False)
				new_element.append(new_id)
			else: # Edge is repeated
				edge_repeated[-new_id] = True
				new_element.append(1-new_id)
		elements.append(new_element)
file_ou.write('End Elements-nodes\n\n')
		
# Printing edge-node connectivities
file_ou.write('Edges\n')
for i in range(len(edges)):
    outp = ' %5d'%(i+1)
    for j in range(len(edges[i])):
        outp += ' %5d'%edges[i][j]
    
    # Indicating wether its a domain edge or a border edge
    if edge_repeated[i]:
        outp += '   D\n'
    else:
        outp += '   B\n'
        
    file_ou.write(outp)

file_ou.write('End Edges\n')
file_ou.write('\n')

# Printing element-edge connectivities
file_ou.write('Elements-edges\n')
for i in range(len(elements)):
	outp = ' %5d'%(i+1)
	for j in range(len(elements[i])):
		outp +=  ' %5d'%(elements[i][j])
	file_ou.write(outp + '\n')
file_ou.write('End Elements-edges\n')
	
file_in.close()
file_ou.close()

print('GiD file transformed successfully')