# Author: Burak Himmetoglu
# Date  : 10-12-2017
# Read charge density from a given pseudo-potential in UPF format 

import numpy as np
import re

def getPP(path_to_pp):
  """ This function reads the pseudo-potential file and returns 
      the grid and radial charge density """

  # Read all of pp_file into pp
  f = open(path_to_pp, 'r')
  pp = f.readlines()
  f.close

  # Read data
  ind = 0
  start_PPR = 0
  start_PPRAB = 0
  start_RHO = 0
  for line in pp:
    if "<PP_R type" in line:
      size = int( re.findall(r'\"(.+?)\"',line.split()[2])[0] )
      ncol = int( re.findall(r'\"(.+?)\"',line.split()[3])[0] )
      start_PPR = ind + 1

    if "<PP_RAB type" in line:
      start_PPRAB = ind +1

    if "<PP_RHOATOM type" in line:
      start_RHO = ind + 1
      break

    ind += 1

  # Find valcene charge, dx, mesh, xmin, rmax, zmesh
  ind = 0
  for line in pp:
    line = line.rstrip() # Remove \n 
    if re.search('Valence configuration:', line):
      start_val = ind + 1

    if re.search('Generation configuration:', line):
      end_val = ind + 1

    if re.search('dx=', line):
      dx = float( re.findall(r'\"(.+?)\"',line.split()[1])[0] )
      mesh = int( re.findall(r'\"(.+?)\"',line.split()[2])[0] )
      xmin = float( re.findall(r'\"(.+?)\"',line.split()[3])[0] )
      rmax = float( re.findall(r'\"(.+?)\"',line.split()[4])[0] )

    if re.search('zmesh=', line):
      zmesh = float( re.findall(r'\"(.+?)\"',line.split()[0])[0] )

      break

    ind += 1

  # Check zmesh
  if (mesh != size):
    raise ValueError("Wrong mesh! expected = %i, obtained = %i" % (mesh, size))

  valence_q = 0.0
  for i in range(start_val+1,end_val-1):
    line = pp[i]
    valence_q += float(line.split()[3])

  # Read PP_R, PP_RAB, and PP_RHO: In the radial mesh grid
  r = np.zeros(size)
  rab = np.zeros(size)
  rho = np.zeros(size)
  nrow = size//ncol
  if size % ncol != 0: # If there are rows with less than ncol columns
    nrow += 1

  offset_r = 0
  for ir in range(nrow):
    line_r = pp[start_PPR + ir]
    line_rab = pp[start_PPRAB + ir]
    line_rho = pp[start_RHO + ir]
    actcol = ncol # Actual number of rows in the current line
    if ir == nrow -1:
      actcol = size - ncol*(nrow-1)

    for ic in range(actcol):
      r[offset_r+ic] = float(line_r.split()[ic])
      rab[offset_r+ic] = float(line_rab.split()[ic])
      rho[offset_r+ic] = float(line_rho.split()[ic])

    offset_r += actcol

  # Check charge
  QQ = np.dot(np.transpose(rho),rab)
  if ( np.abs(QQ - valence_q) > 1e-4):
    raise ValueError("Valence charge wrong!: Expected = %.6f, Obtained = .%6f" % (valence_q, QQ)) 

  # rho is 4*pi*r^2 rho_actual
  rho = rho / (4.0*np.pi*r*r)

  # Return rho, r
  return rho, r
 
