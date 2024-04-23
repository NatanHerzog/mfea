clear all
close all
% clc

l = 10;   %! [m]
E = 1;  %! [N/m^2]
I = 1; %! [m^4]
A = 1;    %! [m^2]
MESH_SIZE = 0.33; %! [m]
F = 1;  %! [N]

S = System(E,I,A);

S.addNode(0,0);
S.addNode(l,0);
S.addNode(2*l,0);
S.addNode(l/2, sqrt(l^2-(l/2)^2));
S.addNode(l/2+l, sqrt(l^2-(l/2)^2));

S.addElement(1,2);
S.addElement(2,3);
S.addElement(1,4);
S.addElement(2,4);
S.addElement(2,5);
S.addElement(3,5);
S.addElement(4,5);

S.xDisplacementCondition([0,0]);
S.yDisplacementCondition([0,0]);
S.yDisplacementCondition([2*l,0]);

S.yNodalForce([l,0],-F);

S.setStiffnessAndLoads;
S.getStiffness
S.getNodalLoads

S.getStiffness \ S.getNodalLoads