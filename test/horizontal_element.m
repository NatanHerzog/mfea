clear all
clc

addpath('../src')

YOUNGS_MODULUS = 1e9;
BASE = 0.25;
HEIGHT = 0.5;
CROSS_SECTIONAL_AREA = BASE * HEIGHT;
SECOND_MOMENT_OF_AREA = 1/12 * BASE * HEIGHT^3;
LENGTH = 3;

nodelist = NodeList;
nodelist.addNodeByLoc(0,0);
nodelist.addNodeByLoc(LENGTH,0);

elementlist = ElementList(CROSS_SECTIONAL_AREA, SECOND_MOMENT_OF_AREA, YOUNGS_MODULUS);
elementlist.linkToNodes(nodelist);
elementlist.addElementByIndices(1,2);

elementlist.setMaterialPropertiesInBulk;
elementlist.calculateOverallStiffness;
elementlist.getStiffnessMatrix