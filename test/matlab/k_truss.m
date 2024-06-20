clear all
clc
format long

addpath('../../src')

%* ----- MATERIAL PROPERTIES ----- *%
YOUNGS_MODULUS = 0.54e6;
LOAD = [0,-5000,0];

%* ----- GEOMETRY DEFINITIONS ----- *%
LENGTH = 18;
NUM_SECTIONS = 6;
SECTION_LENGTH = LENGTH / 6;
ANGLE = 70;
HEIGHT = SECTION_LENGTH * tand(ANGLE);
CROSS_SECTION_BASE = 3/8;
CROSS_SECTION_HEIGHT = 3/8;

%* ----- CROSS-SECTIONAL PROPERTIES ----- *%
CROSS_SECTIONAL_AREA = CROSS_SECTION_BASE * CROSS_SECTION_HEIGHT;
SECOND_MOMENT_OF_AREA = 1/12 * CROSS_SECTION_BASE * CROSS_SECTION_HEIGHT^3;

%* ----- DEFINE A LIST OF NODES ----- *%
nodelist = NodeList;
nodelist.addNodeByLoc(0, 0);                            %! [1]

nodelist.addNodeByLoc(SECTION_LENGTH, 0);               %! [2]
nodelist.addNodeByLoc(SECTION_LENGTH, HEIGHT/2);        %! [3]
nodelist.addNodeByLoc(SECTION_LENGTH, HEIGHT);          %! [4]
nodelist.addNodeByLoc(2*SECTION_LENGTH, 0);             %! [5]
nodelist.addNodeByLoc(2*SECTION_LENGTH, HEIGHT/2);      %! [6]
nodelist.addNodeByLoc(2*SECTION_LENGTH, HEIGHT);        %! [7]

nodelist.addNodeByLoc(3*SECTION_LENGTH, 0);             %! [8]
nodelist.addNodeByLoc(3*SECTION_LENGTH, HEIGHT);        %! [9]

nodelist.addNodeByLoc(4*SECTION_LENGTH, 0);             %! [10]
nodelist.addNodeByLoc(4*SECTION_LENGTH, HEIGHT/2);      %! [11]
nodelist.addNodeByLoc(4*SECTION_LENGTH, HEIGHT);        %! [12]
nodelist.addNodeByLoc(5*SECTION_LENGTH, 0);             %! [13]
nodelist.addNodeByLoc(5*SECTION_LENGTH, HEIGHT/2);      %! [14]
nodelist.addNodeByLoc(5*SECTION_LENGTH, HEIGHT);        %! [15]

nodelist.addNodeByLoc(LENGTH, 0);                       %! [16]


%* ----- DEFINE A LIST OF ELEMENTS ----- *%
elementlist = ElementList(CROSS_SECTIONAL_AREA, SECOND_MOMENT_OF_AREA, YOUNGS_MODULUS);
elementlist.linkToNodes(nodelist);

%* base beam elements
elementlist.addElementByIndices(1,2);
elementlist.addElementByIndices(2,5);
elementlist.addElementByIndices(5,8);
elementlist.addElementByIndices(8,10);
elementlist.addElementByIndices(10,13);
elementlist.addElementByIndices(13,16);

%* edge diagonal elements
elementlist.addElementByIndices(1,4);
elementlist.addElementByIndices(16,15);

%* vertical elements
elementlist.addElementByIndices(2,3);
elementlist.addElementByIndices(3,4);
elementlist.addElementByIndices(5,6);
elementlist.addElementByIndices(6,7);
elementlist.addElementByIndices(8,9);
elementlist.addElementByIndices(10,11);
elementlist.addElementByIndices(11,12);
elementlist.addElementByIndices(13,14);
elementlist.addElementByIndices(14,15);

%* inner diagonal elements
elementlist.addElementByIndices(3,5);
elementlist.addElementByIndices(3,7);
elementlist.addElementByIndices(6,8);
elementlist.addElementByIndices(6,9);
elementlist.addElementByIndices(11,8);
elementlist.addElementByIndices(11,9);
elementlist.addElementByIndices(14,10);
elementlist.addElementByIndices(14,12);

%* top beam elements
elementlist.addElementByIndices(4,7);
elementlist.addElementByIndices(7,9);
elementlist.addElementByIndices(9,12);
elementlist.addElementByIndices(12,15);

%* ----- DEFINE A SYSTEM ----- *%
system = System(elementlist);   %! initialize a system with the elementlist

system.addDisplacement(nodelist.getNode(1), 0, Direction.XTRANSLATION);
system.addDisplacement(nodelist.getNode(1), 0, Direction.YTRANSLATION);

system.addDisplacement(nodelist.getNode(16), 0, Direction.YTRANSLATION);

%! load the interior bottom nodes
system.addLoad(nodelist.getNode(2), LOAD./5);
system.addLoad(nodelist.getNode(5), LOAD./5);
system.addLoad(nodelist.getNode(8), LOAD./5);
system.addLoad(nodelist.getNode(10), LOAD./5);
system.addLoad(nodelist.getNode(13), LOAD./5);

system.solve                                                                              %! solve the system!
system.plotSystem