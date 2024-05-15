classdef ElementList < handle
  properties (GetAccess = private, SetAccess = private)
    elements (1,:) Element
  end

  methods
    %* ----- ELEMENT LIST CONSTRUCTOR ----- *%
    function obj = ElementList(~)
    end

    %* ----- ACCESSOR ----- *%
    function elements = getElements(obj)
      elements = obj.elements;
    end

    function num_elem = len(obj)
      num_elem = length(obj.getElements);
    end

    %* ----- ADD ELEMENT TO LIST ----- *%
    function addElement(obj, n1, n2)
      arguments
        obj ElementList
        n1 (1,1) Node
        n2 (1,1) Node
      end
      e = Element(n1,n2);
      obj.elements = [obj.getElements, e];
    end

    %* ----- GET STIFFNESS MATRIX ----- *%
    function K = getOverallStiffness(obj)
      elements_list = obj.getElements;
      K = zeros(nodes_list.len*3);
      for i=1:obj.len
        e1_i = (elements_list(i).getNodeOne-1)*num_dof+1;
        e2_i = (elements_list(i).getNodeTwo-1)*num_dof+1;
        indices = [e1_i:e1_i+num_dof-1,...
                   e2_i:e2_i+num_dof-1];
        element_stiffness = elements_list(i).getElementStiffness;
        element_transform = elements_list(i).getElementTransformation;
        K(indices,indices) = K(indices,indices) + (transpose(element_transform) * element_stiffness * element_transform);
      end
    end
  end
end