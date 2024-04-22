clear
clc

addpath('src')

S = System(1,1,1);
S.addNode(0,0); S.addNode(1,1); S.addNode(2,1);
S.addElement(1,2); S.addElement(2,3);
S.K
S.xDisplacementCondition([0,0]);
S.yDisplacementCondition([0,0]);
S.rotationCondition([1,1]);
S.setStiffness;
S.getStiffness