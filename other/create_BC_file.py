import sys

if len(sys.argv)< 2:
    raise Exception('Please input a project name')


project = sys.argv[1]

file_in = open('../data/'+project+'/mesh.msh','r')
file_ou = open('../data/'+project+'/boundaries.txt','w+')

coordinates = False

dirichlet = []
neumann = []

for line in file_in:
	
	if not coordinates:
		if line == 'Coordinates\n':
			coordinates = True
		continue
	if line == 'End Coordinates\n':
		break

	data = line.split()
	X = []
	for i in range(3):
		X.append(float(data[1+i]))

	# Boundary conditions:
	if(X[0] == 0 or X[1] == 0 or X[0]==1 or X[1]==1):
        #                   Node ID     Value
		dirichlet.append([int(data[0]),  0.0])

if len(dirichlet)>0:
    file_ou.write('Dirichlet\n')
    for node in dirichlet:
        file_ou.write('%6d %10.5e\n'%(node[0], node[1]))
    file_ou.write('End Dirichlet\n\n')

if len(neumann)>0:
    file_ou.write('Neumann\n')
    for node in neumann:
        file_ou.write('%6d %10.5e\n'%(node[0], node[1]))
    file_ou.write('End Neumann\n')


file_in.close()
file_ou.close()