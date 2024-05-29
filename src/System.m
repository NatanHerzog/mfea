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

    function loads = getLoads(obj)
      loads = obj.loads;
    end
    function displacements = getDisplacements(obj)
      displacements = obj.displacements;
    end

    %* ----- GET STIFFNESS MATRIX ----- *%
    function stiffness_matrix = getSystemStiffness(obj)
      stiffness_matrix = obj.element_list.getStiffnessMatrix;
      displacements = obj.getDisplacements;
      if ~isempty(displacements)
        for displacements_index=1:length(displacements)
          current_displacement_condition = displacements(displacements_index);
        end
      else
        throw(MEexception('system is not constrained, will result in rigid-body motion'));
      end
    end
  end
end