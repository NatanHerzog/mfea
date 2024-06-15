clear all
clc

addpath('../../src')

%* ----- MATERIAL PROPERTIES ----- *%
YOUNGS_MODULUS = 1;

%* ----- GEOMETRY DEFINITIONS ----- *%
LENGTH = 1;
BASE = 1;
HEIGHT = 1;

%* ----- CROSS-SECTIONAL PROPERTIES ----- *%
CROSS_SECTIONAL_AREA = BASE * HEIGHT;
SECOND_MOMENT_OF_AREA = 1/12 * BASE * HEIGHT^3;

%* ----- DEFINE A LIST OF NODES ----- *%
nodelist = NodeList;
nodelist.addNodeByLoc(0,0);                                                               %! create a node at (0,0)
nodelist.addNodeByLoc(LENGTH,0);                                                          %! create a node at (LENGTH,0)

%* ----- DEFINE A LIST OF ELEMENTS ----- *%
elementlist = ElementList(CROSS_SECTIONAL_AREA, SECOND_MOMENT_OF_AREA, YOUNGS_MODULUS);   %! initialize elements with material and cross-sectional properties defined above
elementlist.linkToNodes(nodelist);                                                        %! link the elementlist to the nodelist
elementlist.addElementByIndices(1,2);                                                     %! connect nodes 1 and 2 with an element

%* ----- DEFINE A SYSTEM ----- *%
system = System(elementlist);                                                             %! initialize a system with the elementlist

system.addDisplacement(nodelist.getNode(1), 0, Direction.XTRANSLATION);                   %! fix x-translation of the node at (0,0)
system.addDisplacement(nodelist.getNode(1), 0, Direction.YTRANSLATION);                   %! fix y-translation of the node at (0,0)
system.addDisplacement(nodelist.getNode(1), 0, Direction.ZROTATION);                      %! fix z-rotation of the node at (0,0)

system.addLoad(nodelist.getNode(2), [0,1,0]);                                             %! apply a load [1,0,0] of the node at (LENGTH,0)

system.solve                                                                              %! solve the system!
elementlist.calculateOverallStiffness