function STAddrSpecDescribe(stasSpecification)

% STAddrSpecDescribe - FUNCTION Pretty print an addressing specification
% $Id: STAddrSpecDescribe.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: STAddrSpecDescribe(stasSpecification)
%
% This function will display a user-friendly overview of an addressing
% specification.  All field will be shown, with bit-number extents,
% decriptions (if available) and an indication of whether the bits in the
% field are reversed or not.  Note that the display is never to scale.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004 

% -- Check arguments

if (nargin > 1)
   disp('--- STAddrSpecDescribe: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STAddrSpecDescribe: Incorrect usage');
   help STAddrSpecDescribe;
   return;
end


% -- Check that we have at least the basic addressing requirements

if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecDescribe: An invalid addressing specification was supplied');
   return;
end

% -- Print the address format

% - Fill empty fields in the addressing specification
stasSpecification = STAddrSpecFill(stasSpecification);

% - How many bits in total?
nTotalBits = sum([stasSpecification.nWidth]);

% - Iterate from most to least significant
nCurrMaxBits = nTotalBits;
for (nFieldIndex = length(stasSpecification):-1:1)
   if (FieldExists(stasSpecification(nFieldIndex), 'bReverse') & stasSpecification(nFieldIndex).bReverse)
      sReverse = '<-> ';
   else
      sReverse = '';
   end
   
   if (FieldExists(stasSpecification(nFieldIndex), 'bInvert') & stasSpecification(nFieldIndex).bInvert)
      sDescription = sprintf('~(%s)', stasSpecification(nFieldIndex).Description);
   else
      sDescription = stasSpecification(nFieldIndex).Description;
   end
   
   fprintf(1, '|(%d)  %s %s (%d)', nCurrMaxBits-1, sDescription, sReverse, nCurrMaxBits - stasSpecification(nFieldIndex).nWidth);
   nCurrMaxBits = nCurrMaxBits - stasSpecification(nFieldIndex).nWidth;
end
fprintf(1, '|\n');

% --- END of STAddrSpecDescribe.m ---

% $Log: STAddrSpecDescribe.m,v $
% Revision 2.4  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.3  2004/07/30 10:18:17  dylan
% * Added a new field to addressing specifications: bIgnore will cause a field
% in a hardware address to be binary-inverted when converting to and from
% hardware addresses.
%
% Revision 2.2  2004/07/30 09:00:36  dylan
% Fixed a bug in STAddrSpecIgnoreSYnapseNeuron.m (nonote)
%
% Revision 2.1  2004/07/19 16:21:01  dylan
% * Major update of the spike toolbox (moving to v0.02)
%
% * Modified the procedure for retrieving and setting toolbox options.  The new
% suite of functions comprises of STOptions, STOptionsLoad, STOptionsSave,
% STOptionsDescribe, STCreateGlobals and STIsValidOptionsStruct.  Spike Toolbox
% 'factory default' options are defined in STToolboxDefaults.  Options can be
% saved as user defaults using STOptionsSave, and will be loaded automatically
% for each session.
%
% * Removed STAccessDefaults and STCreateDefaults.
%
% * Renamed STLogicalAddressConstruct, STLogicalAddressExtract,
% STPhysicalAddressContstruct and STPhysicalAddressExtract to
% STAddr<type><verb>
%
% * Drastically modified the way synapse addresses are specified for the
% toolbox.  A more generic approach is now taken, where addressing modes are
% defined by structures that outline the meaning of each bit-field in a
% physical address.  Fields can have their bits reversed, can be ignored, can
% have a description attached, and can be marked as major or minor fields.
% Any type of neuron/synapse topology can be addressed in this way, including
% 2D neuron arrays and chips with no separate synapse addresses.
%
% The following functions were created to handle this new addressing mode:
% STAddrDescribe, STAddrFilterArgs, STAddrSpecChannel, STAddrSpecCompare,
% STAddrSpecDescribe, STAddrSpecFill, STAddrSpecIgnoreSynapseNeuron,
% STAddrSpecInfo, STAddrSpecSynapse2DNeuron, STIsValidAddress, STIsValidAddrSpec,
% STIsValidChannelAddrSpec and STIsValidMonitorChannelsSpecification.
%
% This modification required changes to STAddrLogicalConstruct and Extract,
% STAddrPhysicalConstruct and Extract, STCreate, STExport, STImport,
% STStimulate, STMap, STCrop, STConcat and STMultiplex.
%
% * Removed the channel filter functions.
%
% * Modified STDescribe to handle the majority of toolbox variable types.
% This function will now describe spike trains, addressing specifications and
% spike toolbox options.  Added STAddrDescribe, STOptionsDescribe and
% STTrainDescribe.
%
% * Added an STIsValidSpikeTrain function to test the validity of a spike
% train structure.  Modified many spike train manipulation functions to use
% this feature.
%
% * Added features to Todo.txt, updated Readme.txt
%
% * Added an info.xml file, added a welcome HTML file (spike_tb_welcome.html)
% and associated images (an_spike-big.jpg, an_spike.gif)
%