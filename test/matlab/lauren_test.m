clear all
close all
clc

addpath('../../src')

plotting_scale_factor = 2.372e2;

%* ----- MATERIAL PROPERTIES ----- *%
YOUNGS_MODULUS = 210e9;
LOAD = [0,-8000,0];

%* ----- GEOMETRY DEFINITIONS ----- *%
BOTTOM_PIECE_LENGTH = 2.4;
HEIGHT = 3.6;
CROSS_SECTION_BASE = 5e-2;
CROSS_SECTION_HEIGHT = 2e-2;

%* ----- CROSS-SECTIONAL PROPERTIES ----- *%
CROSS_SECTIONAL_AREA = CROSS_SECTION_BASE * CROSS_SECTION_HEIGHT;
SECOND_MOMENT_OF_AREA = 1/12 * CROSS_SECTION_BASE * CROSS_SECTION_HEIGHT^3;

%* ----- DEFINE A LIST OF NODES ----- *%
nodelist = NodeList;
nodelist.addNodeByLoc(0, 0);
nodelist.addNodeByLoc(BOTTOM_PIECE_LENGTH, 0);
nodelist.addNodeByLoc(2*BOTTOM_PIECE_LENGTH, 0);
nodelist.addNodeByLoc(3*BOTTOM_PIECE_LENGTH, 0);
nodelist.addNodeByLoc(4*BOTTOM_PIECE_LENGTH, 0);

nodelist.addNodeByLoc(BOTTOM_PIECE_LENGTH, HEIGHT/2);
nodelist.addNodeByLoc(2*BOTTOM_PIECE_LENGTH, HEIGHT);
nodelist.addNodeByLoc(3*BOTTOM_PIECE_LENGTH, HEIGHT/2);

%* ----- DEFINE A LIST OF ELEMENTS ----- *%
elementlist = ElementList(CROSS_SECTIONAL_AREA, SECOND_MOMENT_OF_AREA, YOUNGS_MODULUS);
elementlist.linkToNodes(nodelist);
elementlist.addElementByIndices(1,2);
elementlist.addElementByIndices(2,3);
elementlist.addElementByIndices(3,4);
elementlist.addElementByIndices(4,5);

elementlist.addElementByIndices(1,6);
elementlist.addElementByIndices(2,6);
elementlist.addElementByIndices(2,7);

elementlist.addElementByIndices(3,7);

elementlist.addElementByIndices(4,7);
elementlist.addElementByIndices(4,8);
elementlist.addElementByIndices(4,8);

elementlist.addElementByIndices(5,8);

elementlist.addElementByIndices(6,7);
elementlist.addElementByIndices(7,8);

%* ----- DEFINE A SYSTEM ----- *%
system = System(elementlist);   %! initialize a system with the elementlist

system.addDisplacement(nodelist.getNode(1), 0, Direction.YTRANSLATION);

system.addDisplacement(nodelist.getNode(5), 0, Direction.XTRANSLATION);
system.addDisplacement(nodelist.getNode(5), 0, Direction.YTRANSLATION);

system.addLoad(nodelist.getNode(6), LOAD);
system.addLoad(nodelist.getNode(7), LOAD);
system.addLoad(nodelist.getNode(8), LOAD);

system.meshModel(MeshingType.NUM_SUBDIVISIONS, 1);

soln = system.solve;
system.plotSystem(plotting_scale_factor)