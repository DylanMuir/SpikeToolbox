function [bValid] = STIsValidAddrSpec(stasSpecification)

% STIsValidAddrSpec - FUNCTION Test for a valid address specification structure
% $Id: STIsValidAddrSpec.m 124 2005-02-22 16:34:38Z dylan $
%
% Usage: [bValid] = STIsValidAddrSpec(stasSpecification)
%
% Returns true if 'stasSpecification' is a valid address specification, and
% false otherwise.  At least an 'nWidth' field is required for each addressing
% field for the specification to be considered valid.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004

% -- Check arguments

if (nargin > 1)
   disp('--- STIsValidAddrSpec: Extra arguments ignored');
end

if (nargin < 1)
   disp('*** STIsValidAddrSpec: Incorrect usage');
   help STIsValidAddrSpec;
   return;
end


% -- Test for a valid address specification

bValid = false;

if (isempty(stasSpecification))
   % - An empty matrix is not a valid specification
   return;
end

% - Does the 'nWidth' field have an entry for each entry?
for (nFieldIndex = 1:length(stasSpecification))
   if (~FieldExists(stasSpecification(nFieldIndex), 'nWidth'))
      return;
   end
   
   if (FieldExists(stasSpecification(nFieldIndex), 'bRangeCheck') & (stasSpecification(nFieldIndex).bRangeCheck == true))
      % - There should also be a 'nMax' field
      if (~FieldExists(stasSpecification(nFieldIndex), 'nMax'))
         return;
      end
      
      % - The 'nMax' field should not be bigger than the representation
      if (stasSpecification(nFieldIndex).nMax > (2 ^ stasSpecification(nFieldIndex).nWidth - 1))
         return;
      end
   end
end

bValid = true;

% --- END of STIsValidAddrSpec.m ---

% $Log: STIsValidAddrSpec.m,v $
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