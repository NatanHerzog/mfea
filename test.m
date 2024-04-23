clear all
clc

addpath('src')

S = System(1,1,1);
S.addNode(0,0); S.addNode(1,0);
% S.addNode(2,0);
S.addElement(1,2);
% S.addElement(2,3);
S.K
S.xDisplacementCondition([0,0]);
S.xDisplacementCondition([1,0]);
% S.yDisplacementCondition([0,0]);
% S.yDisplacementCondition([2,0]);
% S.rotationCondition([0,0]);
% S.rotationCondition([1,0]);
% S.rotationCondition([2,0]);
S.yNodalForce([0,0],1);
S.yNodalForce([1,0],1);
S.setStiffnessAndLoads;
S.getStiffness
det(S.getStiffness)
S.getNodalLoads

% S.getStiffness \ S.getNodalLoads