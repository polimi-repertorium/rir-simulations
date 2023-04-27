import  pyfar as pf
import matplotlib.pyplot as plt
from pathlib import Path

if __name__ == '__main__':

    # make dir where to save RIRs plot
    RIR_plots_folder = Path("/nas/home/fronchini/rir-simulations/RIRs_plot")
    Path(RIR_plots_folder).mkdir(exist_ok=True)
    
    # path of the SOFA file to read
    filepath = Path("/nas/home/fronchini/rir-simulations/src/lib/data/SOFA/GeneralFIRtest.sofa")

    # read the SOFA file
    audio, source_coordinates, receiver_coordinates = pf.io.read_sofa(str(filepath), verify=True)
    pf.plot.time(audio)

    fig = plt.figure()
    ax1 = pf.plot.time(audio)

    # Save RIRs plot 
    RIR_fig_filename = RIR_plots_folder / "SOFA_test.png"
    fig.savefig(RIR_fig_filename)
    print(f"File has been saved in {RIR_fig_filename}")
