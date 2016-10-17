README - How to use the spike toolbox

$Id: Readme.txt,v 1.1 2004/06/22 12:28:08 dylan Exp $

Installation:
* Add the spike_tb directory to the matlab path
* The spike toolbox requires some utilitiy functions in ../utilities.  
Add this directory to the matlab path.
* The PCI-AER stimulation functions are developmental, but require a 
built copy of stimmon on the path.  Easiest is to add a symbolic link to 
a built version.  stimmon is available in the alavlsi repository, under 
SW/c/poisson.

Usage:
* Type 'help spike_tb' in matlab to get a list of toolbox functions with 
descriptions.  Type 'help STFormats' for some basic information on the 
spike train objects, their representation and usage.
* Most functions have comprehensive help.

--- END of Readme.txt ---

$Log: Readme.txt,v $
Revision 1.1  2004/06/22 12:28:08  dylan
Addded a Readme.txt file to the spike toolbox

