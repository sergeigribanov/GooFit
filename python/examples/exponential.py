#!/usr/bin/env python


import numpy as np

from goofit import *

print_goofit_info()

# Independent variable.
xvar = Observable("xvar", 0, 10)

# Data set
data = UnbinnedDataSet(xvar)

# Generate toy events
xdata = np.random.exponential(size=100000)
data.from_matrix(xdata[np.newaxis, :], filter=True)

# Also would work
# for v in xdata:
#    xvar.value = v
#    data.addEvent()

# Fit parameter
alpha = Variable("alpha", -2, 0.1, -10, 10)

# PDF object
exppdf = ExpPdf("exppdf", xvar, alpha)

# Do the fit
exppdf.fitTo(data)

# exppdf.setData(data)
# fitter = FitManager(exppdf)
# fitter.fit()
