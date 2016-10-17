README - How to use the spike toolbox (v0.02)

$Id: Readme.txt 124 2005-02-22 16:34:38Z dylan $

Installation:
* Add the spike_tb directory to the matlab path
* The spike toolbox requires some utilitiy functions in ../utilities.  
Add this directory to the matlab path.
* The PCI-AER stimulation functions are developmental, but require a 
built copy of stimmon on the path.  Easiest is to add a symbolic link to 
a built version.  stimmon is available in the alavlsi repository, under 
SW/c/poisson.


Help and introduction:
* See 'spike_tb_welcome.html' for a breif introduction to the spike toolbox.
This file is also available unde the Matlab start button (Start ->
Toolboxes -> Spike Toolbox -> Welcome page).


--- END of Readme.txt ---

$Log: Readme.txt,v $
Revision 2.3  2004/07/29 14:04:28  dylan
* Fixed a bug in STAddrLogicalExtract where it would incorrectly handle
addressing specifications with no minor address fields.

* Updated the help for STOptions, making it more verbose.

* Modified the help for STAddrSpecInfo: Added a reference to STDescribe.

* Modifed readme.txt to point to the welcome HTML file.

* Modified the spike_tb_welcome.html file: Added a reference to STDescribe.

* Modified STAddrSpecSynapse2DNeuron: This function now accepts an argument
'bXSecond' which can swap the order of the two neuron address fields.

* Added a more explicit description of 'strPlotOptions' to STPlotRaster.

* Updated STFormats to bring it up to date with the new toolbox variable
formats.

Revision 2.2  2004/07/22 08:27:02  dylan
Updated Readme.txt (nonote)

Revision 2.1  2004/07/19 16:21:00  dylan
* Major update of the spike toolbox (moving to v0.02)

* Modified the procedure for retrieving and setting toolbox options.  The new
suite of functions comprises of STOptions, STOptionsLoad, STOptionsSave,
STOptionsDescribe, STCreateGlobals and STIsValidOptionsStruct.  Spike Toolbox
'factory default' options are defined in STToolboxDefaults.  Options can be
saved as user defaults using STOptionsSave, and will be loaded automatically
for each session.

* Removed STAccessDefaults and STCreateDefaults.

* Renamed STLogicalAddressConstruct, STLogicalAddressExtract,
STPhysicalAddressContstruct and STPhysicalAddressExtract to
STAddr<type><verb>

* Drastically modified the way synapse addresses are specified for the
toolbox.  A more generic approach is now taken, where addressing modes are
defined by structures that outline the meaning of each bit-field in a
physical address.  Fields can have their bits reversed, can be ignored, can
have a description attached, and can be marked as major or minor fields.
Any type of neuron/synapse topology can be addressed in this way, including
2D neuron arrays and chips with no separate synapse addresses.

The following functions were created to handle this new addressing mode:
STAddrDescribe, STAddrFilterArgs, STAddrSpecChannel, STAddrSpecCompare,
STAddrSpecDescribe, STAddrSpecFill, STAddrSpecIgnoreSynapseNeuron,
STAddrSpecInfo, STAddrSpecSynapse2DNeuron, STIsValidAddress, STIsValidAddrSpec,
STIsValidChannelAddrSpec and STIsValidMonitorChannelsSpecification.

This modification required changes to STAddrLogicalConstruct and Extract,
STAddrPhysicalConstruct and Extract, STCreate, STExport, STImport,
STStimulate, STMap, STCrop, STConcat and STMultiplex.

* Removed the channel filter functions.

* Modified STDescribe to handle the majority of toolbox variable types.
This function will now describe spike trains, addressing specifications and
spike toolbox options.  Added STAddrDescribe, STOptionsDescribe and
STTrainDescribe.

* Added an STIsValidSpikeTrain function to test the validity of a spike
train structure.  Modified many spike train manipulation functions to use
this feature.

* Added features to Todo.txt, updated Readme.txt

* Added an info.xml file, added a welcome HTML file (spike_tb_welcome.html)
and associated images (an_spike-big.jpg, an_spike.gif)

Revision 2.0  2004/07/13 12:56:30  dylan
Moving to version 0.02 (nonote)

Revision 1.2  2004/07/13 12:55:18  dylan
(nonote)

Revision 1.1  2004/06/22 12:28:08  dylan
Addded a Readme.txt file to the spike toolbox

