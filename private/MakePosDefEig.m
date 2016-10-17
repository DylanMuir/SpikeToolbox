function mfMatrix = MakePosDefEig(mfMatrix)

% - Eigenvalue decomposition
bContinue = true;
while (bContinue)
   [v,d] = eig(mfMatrix);
   d = diag(d);
   
   [fEig, nLargestNeg] = nanmin(d .* (d < 0));
   if (fEig == 0)
      bContinue = false;
      continue;
   end
   
   vfVec = v(:, nLargestNeg);
   mfMatrix = mfMatrix + vfVec*vfVec' * (eps(mfMatrix(nLargestNeg, nLargestNeg)) - mfMatrix(nLargestNeg, nLargestNeg));
end

