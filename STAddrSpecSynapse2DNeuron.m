function [stasSpecification] = STAddrSpecSynapse2Deuron(nSynapseBits, nXNeuronBits, nYNeuronBits, ...
                                                           nSynapseMax, nXNeuronMax, nYNeuronMax, ...
                                                           bInvertSynapse, bInvertXNeuron, bInvertYNeuron, ...
                                                           bXSecond)

% STAddrSpecSynapse2DNeuron - FUNCTION Address specification utility function
% $Id: STAddrSpecSynapse2DNeuron.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [stasSpecification] = STAddrSpecSynapse2DNeuron(nSynapseBits, nXNeuronBits, nYNeuronBits)
%        [stasSpecification] = STAddrSpecSynapse2DNeuron(nSynapseBits, nXNeuronBits, nYNeuronBits, 
%                                                           nSynapseMax, nXNeuronMax, nYNeuronMax, 
%                                                           bInvertSynapse, bInvertXNeuron, bInvertYNeuron,
%                                                           bXSecond)
%
% This function returns an address specification structure for use with the
% Spike Toolbox.  This specification will contain a single synapse address
% field and a two-dimensional neuron address field, all with user-specified
% widths.  The neuron address field is most significant.
%
% The user can optionally specify an integer maximum for each field.  If this
% is supplied, then addresses will be range checked.  If a width of zero is
% specified for any field, this field will not be included in the
% specification.
%
% The user can optionally supply 'bInvert...' specifications for each
% addressing field.  If 'bInvert...' is true, that field will be binary
% inverted before addresses are sent to neuron hardware.
%
% The user can optionally specify 'bXSecond'.  If this binary value is true,
% then the second neuron field will be labelled as the X field, and the first
% as the Y field.  By default, the X field comes first (is lower order in the
% address).
%
% Type 'help STAddrSpecInfo' for information about specifying address formats.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004

% -- Check arguments

if (nargin > 10)
   disp('--- STAddrSpecSynapse2DNeuron: Extra arguments ignored');
end

if (nargin < 3)
   disp('*** STAddrSpecSynapse2DNeuron: Incorrect usage');
   help STAddrSpecSynapse2DNeuron;
   return;
end

bRangeCheckSynapse = true;
bRangeCheckXNeuron = true;
bRangeCheckYNeuron = true;

if (nargin < 4)
   bRangeCheckSynapse = false;
   nSynapseMax = [];
end

if (nargin < 5)
   bRangeCheckXNeuron = false;
   nXNeuronMax = [];
end

if (nargin < 6)
   bRangeCheckYNeuron = false;
   nYNeuronMax = [];
end

if (nargin < 7)
   bInvertSynapse = false;
end

if (nargin < 8)
   bInvertXNeuron = false;
end

if (nargin < 9)
   bInvertYNeuron = false;
end

if (nargin < 10)
   bXSecond = false;
end


% -- Make the address specification structure

nFieldIndex = 1;

if (nSynapseBits > 0)
   % - Synapse address field
   clear field;
   field.Description = 'Synapse address';
   field.nWidth = nSynapseBits;
   field.bReverse = false;
   field.bInvert = bInvertSynapse;
   field.bMajorField = false;
   field.bRangeCheck = bRangeCheckSynapse;
   if (bRangeCheckSynapse | bRangeCheckXNeuron | bRangeCheckYNeuron)
      field.nMax = nSynapseMax;
   end
   field.bIgnore = false;
   
   stasSpecification(nFieldIndex) = field;
   nFieldIndex = nFieldIndex + 1;
end

if (~bXSecond)
   nNeuronBits = nXNeuronBits;
   strDesc = 'Neuron X address';
   bRangeCheck = bRangeCheckXNeuron;
   bInvert = bInvertXNeuron;
   nNeuronMax = nXNeuronMax;
else
   nNeuronBits = nYNeuronBits;
   strDesc = 'Neuron Y address';
   bRangeCheck = bRangeCheckYNeuron;
   bInvert = bInvertYNeuron;
   nNeuronMax = nYNeuronMax;
end

if (nNeuronBits > 0)
   % - Neuron address field
   clear field;
   field.Description = strDesc;
   field.nWidth = nNeuronBits;
   field.bReverse = false;
   field.bInvert = bInvert;
   field.bMajorField = true;
   field.bRangeCheck = bRangeCheck;
   if (bRangeCheckXNeuron | bRangeCheckYNeuron | bRangeCheckSynapse)
      field.nMax = nNeuronMax;
   end
   field.bIgnore = false;

   stasSpecification(nFieldIndex) = field;
   nFieldIndex = nFieldIndex + 1;
end

if (bXSecond)
   nNeuronBits = nXNeuronBits;
   strDesc = 'Neuron X address';
   bRangeCheck = bRangeCheckXNeuron;
   bInvert = bInvertXNeuron;
   nNeuronMax = nXNeuronMax;
else
   nNeuronBits = nYNeuronBits;
   strDesc = 'Neuron Y address';
   bRangeCheck = bRangeCheckYNeuron;
   bInvert = bInvertYNeuron;
   nNeuronMax = nYNeuronMax;
end

if (nNeuronBits > 0)
   % - Neuron address field
   clear field;
   field.Description = strDesc;
   field.nWidth = nNeuronBits;
   field.bReverse = false;
   field.bInvert = bInvert;
   field.bMajorField = true;
   field.bRangeCheck = bRangeCheck;
   if (bRangeCheckXNeuron | bRangeCheckYNeuron | bRangeCheckSynapse)
      field.nMax = nNeuronMax;
   end
   field.bIgnore = false;

   stasSpecification(nFieldIndex) = field;
   nFieldIndex = nFieldIndex + 1;
end


% - Check to make sure it's a valid spec
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecSynapse2DNeuron: Invalid specification supplied');
   clear stasSpecification;
   return;
end

% --- END of STAddrSpecSynapse2DNeuron ---

% $Log: STAddrSpecSynapse2DNeuron.m,v $
% Revision 2.4  2004/09/16 11:45:22  dylan
% Updated help text layout for all functions
%
% Revision 2.3  2004/07/30 10:18:17  dylan
% * Added a new field to addressing specifications: bIgnore will cause a field
% in a hardware address to be binary-inverted when converting to and from
% hardware addresses.
%
% Revision 2.2  2004/07/29 14:04:29  dylan
% * Fixed a bug in STAddrLogicalExtract where it would incorrectly handle
% addressing specifications with no minor address fields.
%
% * Updated the help for STOptions, making it more verbose.
%
% * Modified the help for STAddrSpecInfo: Added a reference to STDescribe.
%
% * Modifed readme.txt to point to the welcome HTML file.
%
% * Modified the spike_tb_welcome.html file: Added a reference to STDescribe.
%
% * Modified STAddrSpecSynapse2DNeuron: This function now accepts an argument
% 'bXSecond' which can swap the order of the two neuron address fields.
%
% * Added a more explicit description of 'strPlotOptions' to STPlotRaster.
%
% * Updated STFormats to bring it up to date with the new toolbox variable
% formats.
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