#!/usr/bin/env python
from scipy import *
from matplotlib import *
from pylab import *
from scipy.optimize import leastsq
# fix pe
#
import sys
import csv
"""
Example of curve fitting for
a1*exp(-k1*t) + a2*exp(-k2*t)
"""

file_in = sys.argv[1]
#f1= csv.reader(open(file_in,'r'))
f1=open(file_in,'r')
t=[]
data=[]
for line in f1:
    line = line.rstrip()
#    print line
    fields = line.split()
#    print fields
#    print fields[0],fields[1]
    #print fields
    t.append(float(fields[0]))
    data.append(float(fields[1]))
    
t=array(t)

#print t
#print data

# y=N*(1-EXP(-x/N))+x*p_e

def dbexpl(t,p):
    return(p[0]*(1-exp(-81*t/p[0])) )
#a1,a2 = 1.0, 1.0
#k1,k2 = 0.05, 0.2
#t=arange(0,100,0.1)
#data = dbexpl(t,[100000,0.01]) + 0.02*randn(len(t))
#print data


def residuals(p,data,t):
    err = data - dbexpl(t,p)
    return err
p0 = [float(sys.argv[2])] # initial guesses
guessfit = dbexpl(t,p0)
pbest = leastsq(residuals,p0,args=(data,t),full_output=1)
bestparams = pbest[0]
cov_x = pbest[1]
print 'best fit parameters ',bestparams
#print cov_x
datafit = dbexpl(t,bestparams)
plot(t,data,'x',t,datafit,'ro',t,guessfit)

#for i in range(90):
#    print t[i],data[i],datafit[i],guessfit[i]

xlabel('# of consumed reads')
ylabel('# of unique kmers')
title(sys.argv[4])
grid(True)
show()
