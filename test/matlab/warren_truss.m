clear all
close all
clc

addpath('../../src')

%* ----- MATERIAL PROPERTIES ----- *%
YOUNGS_MODULUS = 0.54e6;
LOAD = [0,-5000,0];

%* ----- GEOMETRY DEFINITIONS ----- *%
LENGTH = 18;
ANGLE = 60;
HEIGHT = (LENGTH / 4) * tand(ANGLE);
CROSS_SECTION_BASE = 3/8;
CROSS_SECTION_HEIGHT = 3/8;

%* ----- CROSS-SECTIONAL PROPERTIES ----- *%
CROSS_SECTIONAL_AREA = CROSS_SECTION_BASE * CROSS_SECTION_HEIGHT;
SECOND_MOMENT_OF_AREA = 1/12 * CROSS_SECTION_BASE * CROSS_SECTION_HEIGHT^3;

%* ----- DEFINE A LIST OF NODES ----- *%
nodelist = NodeList;
nodelist.addNodeByLoc(0, 0);
nodelist.addNodeByLoc(LENGTH * 1/2, 0);
nodelist.addNodeByLoc(LENGTH, 0);
nodelist.addNodeByLoc(LENGTH * 1/4, HEIGHT);
nodelist.addNodeByLoc(LENGTH * 3/4, HEIGHT);

%* ----- DEFINE A LIST OF ELEMENTS ----- *%
elementlist = ElementList(CROSS_SECTIONAL_AREA, SECOND_MOMENT_OF_AREA, YOUNGS_MODULUS);
elementlist.linkToNodes(nodelist);
elementlist.addElementByIndices(1,2);
elementlist.addElementByIndices(2,3);
elementlist.addElementByIndices(1,4);
elementlist.addElementByIndices(2,4);
elementlist.addElementByIndices(2,5);
elementlist.addElementByIndices(3,5);
elementlist.addElementByIndices(4,5);

%* ----- DEFINE A SYSTEM ----- *%
system = System(elementlist);   %! initialize a system with the elementlist

system.addDisplacement(nodelist.getNode(1), 0, Direction.XTRANSLATION);
system.addDisplacement(nodelist.getNode(1), 0, Direction.YTRANSLATION);

system.addDisplacement(nodelist.getNode(3), 0, Direction.YTRANSLATION);

system.addLoad(nodelist.getNode(2), LOAD);

system.meshModel(MeshingType.NUM_SUBDIVISIONS, 50);

system.solve;
system.plotSystem