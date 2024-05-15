clear all
close all
clc

addpath('../src')

LENGTH = 1;            %! [m]
YOUNGS_MODULUS = 1;   %! [N/m^2]
SECOND_MOMENT = 1;      %! [m^4]
AREA = 1;               %! [m^2]
MESH_SIZE = 1;       %! [m]
FORCE = 1;            %! [N]
NUM_DOF = 2;

%* -------------------------------------------------- *%
%* ONE HORIZONTAL ELEMENT

one_horizontal_element = System(YOUNGS_MODULUS, SECOND_MOMENT, AREA, NUM_DOF);

one_horizontal_element.addNode(0,0);
one_horizontal_element.addNode(1,0);
one_horizontal_element.addElement(1,2);
one_horizontal_element.xDisplacementCondition([0,0]);
one_horizontal_element.yDisplacementCondition([0,0]);
one_horizontal_element.yDisplacementCondition([1,0]);
one_horizontal_element.xNodalForce([1,0], FORCE);

disp("System-wide Stiffness Matrix")
disp(one_horizontal_element.K)
one_horizontal_element.setStiffnessAndLoads;
d = one_horizontal_element.getStiffness \ one_horizontal_element.getNodalLoads;
disp("Displacement of Deformed Nodes")
disp(d)
%* -------------------------------------------------- *%



%* -------------------------------------------------- *%
%* ONE VERTICAL ELEMENT

one_vertical_element = System(YOUNGS_MODULUS, SECOND_MOMENT, AREA, NUM_DOF);

one_vertical_element.addNode(0,0);
one_vertical_element.addNode(0,1);
one_vertical_element.addElement(1,2);
one_vertical_element.xDisplacementCondition([0,0]);
one_vertical_element.xDisplacementCondition([0,1]);
one_vertical_element.yDisplacementCondition([0,0]);
one_vertical_element.yNodalForce([0,1], FORCE);

disp("System-wide Stiffness Matrix")
disp(one_vertical_element.K)
one_vertical_element.setStiffnessAndLoads;
d = one_vertical_element.getStiffness \ one_vertical_element.getNodalLoads;
disp("Displacement of Deformed Nodes")
disp(d)
%* -------------------------------------------------- *%