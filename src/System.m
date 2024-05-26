classdef System < handle
  properties (GetAccess = private, SetAccess = private)
    element_list ElementList
    loads (1,:) LoadCondition
    displacements (1,:) DisplacementCondition
  end

  methods
    %* ----- CLASS CONSTRUCTOR ----- *%
    function obj = System(element_list)
      arguments
        element_list ElementList
      end
      obj.element_list = element_list;
    end

    %* ----- ADDER METHODS ----- *%
    function addLoad(obj, load)
      arguments
        obj System
        load (1,1) LoadCondition
      end
      obj.loads = [obj.loads, load];
    end
    function addDisplacement(obj, displacement)
      arguments
        obj System
        displacement (1,1) DisplacementCondition
      end
      obj.displacements = [obj.displacements, displacement];
    end
  end
end