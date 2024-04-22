clear
clc

addpath('src')

nl = NodeList();
nl.addNode(0,0);
nl.addNode(1,1);
nl.addNode(2,1);

el = ElementList();
el.addElement(1,2);
el.addElement(2,3);

K_1 = el.getStiffness(nl)