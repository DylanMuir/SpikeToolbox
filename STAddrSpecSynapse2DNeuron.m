function [stasSpecification] = STAddrSpecSynapse2DNeuron(nSynapseBits, nXNeuronBits, nYNeuronBits, ...
                                                            nSynapseMax, nXNeuronMax, nYNeuronMax, ...
                                                            bInvertSynapse, bInvertXNeuron, bInvertYNeuron, ...
                                                            bXSecond)

% STAddrSpecSynapse2DNeuron - FUNCTION Address specification utility function
% $Id: STAddrSpecSynapse2DNeuron.m 3987 2006-05-09 13:38:38Z dylan $
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
% See the toolbox documentation for information about address
% specifications.

% Author: Dylan Muir <dylan@ini.phys.ethz.ch>
% Created: 14th July, 2004
% Copyright (c) 2004, 2005 Dylan Richard Muir

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
   if (bRangeCheckSynapse || bRangeCheckXNeuron || bRangeCheckYNeuron)
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
   if (bRangeCheckXNeuron || bRangeCheckYNeuron || bRangeCheckSynapse)
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
   if (bRangeCheckXNeuron || bRangeCheckYNeuron || bRangeCheckSynapse)
      field.nMax = nNeuronMax;
   end
   field.bIgnore = false;

   stasSpecification(nFieldIndex) = field;
   % nFieldIndex = nFieldIndex + 1;
end


% - Check to make sure it's a valid spec
if (~STIsValidAddrSpec(stasSpecification))
   disp('*** STAddrSpecSynapse2DNeuron: Invalid specification supplied');
   clear stasSpecification;
   return;
end

% --- END of STAddrSpecSynapse2DNeuron ---
