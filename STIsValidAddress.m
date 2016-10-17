function [bValid] = STIsValidAddress(varargin)

% STIsValidAddress - FUNCTION Checks for a valid address for a given addressing specification
% $Id: STIsValidAddress.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [bValid] = STIsValidAddress(nAddr1, nAddr2, ...)
%        [bValid] = STIsValidAddress(stasSpecification, nAddr1, nAddr2, ...)
%
% This function will check an address against an addressing specification.  If
% no specification is supplied in the argument list, then the default output
% specification will be used from the toolbox options.
%
% An index should be supplied for each non-ignored field in the address
% specification.  Extra indices will be ignored, but do not make an address
% invalid.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 16th July, 2004

% -- Get options

stOptions = STOptions;


% -- Check arguments

if (nargin == 0)
   disp('--- STIsValidAddress: Incorrect usage');
   help STIsValidAddress;
   return;
end

% - Filter the address arguments
[stasSpecification, varargin] = STAddrFilterArgs(varargin{:});

% - Check that we were supplied with a valid specification
if (~STIsValidAddrSpec(stasSpecification))
   disp('--- STIsValidAddress: An invalid addressing specification was supplied');
   return;
end

% - Fill out the specification
stasSpecification = STAddrSpecFill(stasSpecification);

% -- Test for a valid address

bValid = false;

% - Do we have at least enough addressing fields?
nRequiredFields = sum(~[stasSpecification.bIgnore]);

if (length(varargin) < nRequiredFields)
   % - We don't have enough fields
   disp('--- STIsValidAddress: Not enough address fields supplied for given');
   disp('                      addressing specification');
   return;
end;

% - Are the addressing fields all doubles?
vbIsDouble = CellForEach(@isa, varargin, 'double');
if (~min(vbIsDouble))
   disp('--- STIsValidAddress: All address indices must be of class ''double''');
   return;
end

% - Range check the fields
nFieldIndex = 1;
for (nEntryIndex = 1:length(stasSpecification))
   if (~stasSpecification(nEntryIndex).bIgnore)
      if (stasSpecification(nEntryIndex).bRangeCheck)
         % - User-supplied field maximum
         nFieldMax = stasSpecification(nEntryIndex).nMax;
      else
         % - Clip to field extents
         nFieldMax = (2 ^ stasSpecification(nEntryIndex).nWidth - 1);
      end
      
      % - Test all field values for the corresponding field range
      if (max(varargin{nFieldIndex} > nFieldMax))
         % - Out of range
         fprintf(1, '--- STIsValidAddress: Field [%d] is out of range (> [%d])\n', nFieldIndex, nFieldMax);
         return;
      end
      
      nFieldIndex = nFieldIndex + 1;
   end
end

% - Passed the tests
bValid = true;


% --- END of STIsValidAddress.m ---

% $Log: STIsValidAddress.m,v $
% Revision 2.2  2004/09/16 11:45:23  dylan
% Updated help text layout for all functions
%
% Revision 2.1  2004/07/19 16:21:02  dylan
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