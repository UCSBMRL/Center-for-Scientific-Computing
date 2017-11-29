# Imports
import time
import sys
import numpy as np
from scipy.integrate import odeint 
from sklearn.model_selection import ParameterGrid 
import concurrent.futures 

## Equations to be integrated
def eom(y, t, b, c):
	"""
	y   : [th, om] where om = d(th)/dt
	t   : time (sec)
	b,c : parameters 
	"""
	th, om = y

	# Equations
	dot_th = om
	dot_om = -b*om - c*np.sin(th)

	# Return
	return [dot_th, dot_om]

## Set the grid for the initial condition space
def set_parameter_grid(rTh = (-0.25*np.pi, 0.25*np.pi), rOm = (-1,1), size = 100):
	"""
	Function for creating a grid of initial conditions
	rTh    : range of th (-0.25*pi,0.25*pi)
	rOm    : range of om
	size   : Number of samples per theta and omega

	Returns a dictionary containing a grid of initial conditions
	"""
	ths = np.random.uniform(rTh[0], rTh[1], size)
	oms = np.random.uniform(rOm[0], rOm[1], size)

	param_grid = {'th0':ths, 'om0':oms}
	grid = ParameterGrid(param_grid)

	return grid

if __name__ == "__main__":

	# Read size from standard input
	size = int(sys.argv[1])

	# Specity t
	duration = 90
	npts = 401

	# Parameters in the equation
	b = 0.05
	c = 4.0

	# Time grid
	t = np.linspace(0,duration,npts)

	# Grid of initial conditions
	init_conds = list(set_parameter_grid(size=size))
	totlen = len(init_conds)

	# Initiate empty array to save solutions
	dofs = np.zeros((totlen, len(t), 2))

	# Loop over the grid and integrate for each initial condition
	print("Integrating ODE for {:d} initial conditions".format(size*size))
	ii = 0
	start_t = time.time()
	for params in init_conds:
		y0 = [params['th0'], params['om0']]
		sol = odeint(eom, y0, t, args = (b, c))
		
		# Save
		dofs[ii] = sol
		ii +=1

	# Execution time
	execution_t = time.time() - start_t
	print("Execution time (serial): {:.4f} s".format(execution_t))

	## Parallel version
	# Simulate for all the initial conditions
	def simulate_all(init_conds):
		"""
		Simulate for a grid of initial conditions
		"""

		# Get grid size
		totlen = len(init_conds)

		# Initiate empty array
		dofs = np.zeros((totlen, len(t), 2))

		# Iterate
		ii = 0
		for params in init_conds:
			y0 = [params['th0'], params['om0']]
			sol = odeint(eom, y0, t, args = (b, c))

			# Save on dofs array
			dofs[ii] = sol
			ii +=1

		# Return
		return dofs

	# Parallel executor
	executor = concurrent.futures.ProcessPoolExecutor()
	n_workers = executor._max_workers
	case_per_worker = totlen // n_workers

	# Print report
	print("Total number of workers = {:d}".format(n_workers))
	print("Instances per worker = {:d}".format(case_per_worker))

	# Split the list of initial conditions between the workers
	splits = []
	for w in range(n_workers):
    		splits.append(init_conds[w*case_per_worker:(w+1)*case_per_worker])

	# Obtain results in parallel
	start_t = time.time()
	arrs = list(executor.map(simulate_all, splits))
	execution_t = time.time() - start_t

	# Print report
	print("Parallel execution complete, saving arrays...")

	# Concatenate arrays
	final_arr = np.concatenate(arrs, axis=0)

	# Save in file
	np.save('solution.npy',final_arr)

	print("Execution time (parallel) : {:.4f} s".format(execution_t))
	print("Are the two results identical?:", np.allclose(final_arr, dofs))
