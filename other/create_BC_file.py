file_in = open('mesh.msh','r')
file_ou = open('boundaries.txt','w+')

file_ou.write('Dirichlet\n')

coordinates = False

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
	if(X[1] == 0):
		file_ou.write('%6d   %10.5f\n'%(int(data[0]), 0))
#	elif(X[1]==1 or X[0]==1):
#		file_ou.write('%6d   %10.5f\n'%(int(data[0]), 0))

file_ou.write('End Dirichlet\n')

file_in.close()
file_ou.close()