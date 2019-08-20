# SAPPIY | Signal Acquisition & Processing, Program It Yourself
![Alt text](guideline.PNG =250x250 ?raw=true "Optional Title")
The SAPPIY application is a Matlab program dedicated to data acquisition (live mode) and processing (analyze mode) of the time domain signals.

The Live Mode requires the Matlab Data Acquistion Toolbox as well as data acquisition device (DAQ) to be installed on your machine.

The Analyze Mode does not require any specific toolbox and enable processing signal sequences (of the time domain) acquired from the SAPPIY live mode or from any other sources (if the data format respects the application requirements; see user guide).

The application includes internal and external libraries, the latter being designed as "user functions". These user functions allow users to add, edit or delete Matlab functions that can be used under the software, and then customize functions to their use in either the live mode or the analyze mode.

The user guide available with the SAPPIY application helps users to create "user functions". Therefore, the application is an opened program, dedicated to a specific use (data acquistion and processing), with customizable libraries for signal acquisition and processing methods.

The SAPPIY application has been developped with Win 10 and Matlab R2018b.
Users might encouter issues using different OS or Matlab versions. Feel free to share your issues to give me a chance to fix them.
