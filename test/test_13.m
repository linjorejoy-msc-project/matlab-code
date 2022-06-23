clear;
clc;

% cycle flags
global cycle_flags;
cycle_flags = containers.Map;
cycle_flags('motion') = false;
cycle_flags('atmosphere') = true;
cycle_flags('field') = true;



flag = true;
for key = keys(cycle_flags)
   if ~cycle_flags(key{1})
       flag = false;
       break;
   end
end
flag