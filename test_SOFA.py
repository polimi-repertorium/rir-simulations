
filepath = '/Users/francescaronchini/repertorium/rir-simulations/src/lib/data/SOFA/GeneralFIRtest.sofa'
import  pyfar as pf
import matplotlib.pyplot as plt


audio, coordinates, coordinates = pf.io.read_sofa(filepath, verify=True)
pf.plot.time(audio)


fig = plt.figure()
ax1 = pf.plot.time(audio)

# Save the full figure...
fig.savefig('/Users/francescaronchini/repertorium/rir-simulations/full_figure.png')