clear all
close all
clc

addpath('src')

NUM_DOF = 2;

LENGTH = 10;   %! [m]
YOUNGS_MODULUS = 1e9;  %! [N/m^2]
SECOND_MOMENT = 1; %! [m^4]
AREA = 1;    %! [m^2]
MESH_SIZE = 0.33; %! [m]
FORCE = 1e4;  %! [N]

S = System(YOUNGS_MODULUS,SECOND_MOMENT,AREA,NUM_DOF);

S.addNode(0,0);
S.addNode(LENGTH,0);
S.addNode(2*LENGTH,0);
S.addNode(LENGTH/2, sqrt(LENGTH^2-(LENGTH/2)^2));
S.addNode(LENGTH/2+LENGTH, sqrt(LENGTH^2-(LENGTH/2)^2));

S.addElement(1,2);  %! connect node 1->2
S.addElement(2,3);  %! connect node 2->3
S.addElement(1,4);  %! connect node 1->4
S.addElement(2,4);  %! connect node 2->4
S.addElement(2,5);  %! connect node 2->5
S.addElement(3,5);  %! connect node 3->5
S.addElement(4,5);  %! connect node 4->5

S.xDisplacementCondition([0,0]);          %! constrain left end in x
S.yDisplacementCondition([0,0]);          %! constrain left end in y
S.xDisplacementCondition([2*LENGTH,0]);   %! constrain right end in x
S.yDisplacementCondition([2*LENGTH,0]);   %! constrain right end in y

S.yNodalForce([LENGTH,0],-FORCE);  %! apply force at bottom-beam center

S.K
S.setStiffnessAndLoads;
S.getStiffness
S.getNodalLoads

S.getStiffness \ S.getNodalLoads