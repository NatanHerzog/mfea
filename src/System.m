classdef System < handle
  properties (GetAccess = private, SetAccess = private)
    element_list ElementList
    loads (1,:) LoadCondition
    displacements (1,:) DisplacementCondition
    mesh_size (1,1) double = 0
    num_subdivisions (1,1) uint64 = 0

    meshed_element_list ElementList

    nodal_solution (1,:) double
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
    function addLoad(obj, node, load_vector)
      arguments
        obj System
        node (1,1) Node
        load_vector (1,3) double
      end
      load = LoadCondition(node, load_vector);
      obj.loads = [obj.loads, load];
    end
    function addDisplacement(obj, node, displacement, direction)
      arguments
        obj System
        node (1,1) Node
        displacement (1,1) double
        direction Direction
      end
      displacement = DisplacementCondition(node, displacement, direction);
      obj.displacements = [obj.displacements, displacement];
    end

    function setMeshSize(obj, mesh_size)
      arguments
        obj System
        mesh_size (1,1) double
      end
      obj.mesh_size = mesh_size;
    end
    function setNumSubDivisions(obj, num_subdivisions)
      arguments
        obj System
        num_subdivisions (1,1) uint64
      end
      obj.num_subdivisions = num_subdivisions;
    end
    function setMeshParameter(obj, meshing_type, mesh_value)
      arguments
        obj System
        meshing_type MeshingType
        mesh_value (1,1)
      end
      switch meshing_type
        case MeshingType.NUM_SUBDIVISIONS
          obj.setNumSubDivisions(mesh_value);
        case MeshingType.MESH_SIZE
          obj.setMeshSize(mesh_value);
      end
    end

    function meshModel(obj, meshing_type, mesh_value)
      arguments
        obj System
        meshing_type MeshingType
        mesh_value (1,1)
      end
      obj.setMeshParameter(meshing_type, mesh_value);
      switch meshing_type
        case MeshingType.NUM_SUBDIVISIONS
          obj.meshByNumSubdivision(mesh_value);
        case MeshingType.MESH_SIZE
          obj.meshByMeshSize(mesh_value);
      end
    end

    function meshByNumSubdivision(obj, num_subdivisions)
      arguments
        obj System
        num_subdivisions (1,1) uint64
      end
      meshed_element_nodelist = NodeList;
      meshed_elementlist = ElementList(obj.element_list.getCrossSectionalArea, obj.element_list.getSecondMoment, obj.element_list.getYoungsModulus);
      meshed_elementlist.linkToNodes(meshed_element_nodelist);
      for i = 1 : obj.element_list.len
        current_element = obj.element_list.getElementByIndex(i);
        current_element_length = current_element.getElementLength;
        interior_element_length = current_element_length / double(num_subdivisions);
        current_element_direction = current_element.getElementDirection;
        meshed_element_nodelist.addNodeByNode(current_element.getNodeOne);
        starting_nodelist_index = meshed_element_nodelist.len;
        starting_point = [current_element.getNodeOne.getX, current_element.getNodeOne.getY];
        for j = 1 : num_subdivisions - 1
          new_node_location = starting_point + current_element_direction * (interior_element_length * double(j));
          meshed_element_nodelist.addNodeByLoc(new_node_location(1), new_node_location(2));
        end
        meshed_element_nodelist.addNodeByNode(current_element.getNodeTwo);
        for j = starting_nodelist_index : starting_nodelist_index + num_subdivisions - 1
          meshed_elementlist.addElementByNodes(meshed_element_nodelist.getNode(j), meshed_element_nodelist.getNode(j+1));
        end
      end
      meshed_element_nodelist.makeUnique;
      obj.meshed_element_list = meshed_elementlist;
    end

    function loads = getLoads(obj)
      loads = obj.loads;
    end
    function displacements = getDisplacements(obj)
      displacements = obj.displacements;
    end

    function constrained_stiffness_matrix_indices = constrainedStiffnessMatrixIndices(obj, nodes)
      arguments
        obj System
        nodes (1,:) Node
      end
      all_displacements = obj.getDisplacements;
      constrained_stiffness_matrix_indices = uint64.empty(0, length(all_displacements));
      for displacements_index = 1 : length(all_displacements)
        applied_node = all_displacements(displacements_index).getNode;
        applied_node_index = find(nodes == applied_node);
        full_matrix_indices = nodeListIndexToStiffnessIndices(applied_node_index);
        full_matrix_indices(all_displacements(displacements_index).getDirection.real);
        constrained_stiffness_matrix_indices(displacements_index) = full_matrix_indices(all_displacements(displacements_index).getDirection.real);
      end
    end

    function global_load_vector = compileGlobalLoadVector(obj, nodes)
      arguments
        obj System
        nodes (1,:) Node
      end
      all_loads = obj.getLoads;
      global_load_vector = zeros(length(nodes) * 3, 1);
      for load_index = 1 : length(all_loads)
        applied_node = all_loads(load_index).getNode;
        applied_node_index = find(nodes == applied_node);
        full_matrix_indices = nodeListIndexToStiffnessIndices(applied_node_index);
        global_load_vector(full_matrix_indices) = all_loads(load_index).getLoadVector;
      end
    end

    %* ----- SOLVE NODAL DISPLACEMENTS ----- *%
    function all_nodal_displacements = solveNodalDisplacements(obj)
      obj.meshed_element_list.setMaterialPropertiesInBulk;
      obj.meshed_element_list.calculateOverallStiffness;
      all_displacements = obj.getDisplacements;
      if ~isempty(all_displacements)
        all_system_nodes = obj.meshed_element_list.getNodeList.getAllNodes;
        all_nodal_displacements = zeros(1, length(all_system_nodes) * 3);
        
        unfixed_indices = 1:(length(all_system_nodes) * 3);
        constrained_stiffness_matrix_indices = obj.constrainedStiffnessMatrixIndices(all_system_nodes);
        unfixed_indices(constrained_stiffness_matrix_indices) = [];

        global_load_vector = obj.compileGlobalLoadVector(all_system_nodes);
        global_load_vector(constrained_stiffness_matrix_indices) = [];

        stiffness_matrix = obj.meshed_element_list.getStiffnessMatrix;
        stiffness_matrix(constrained_stiffness_matrix_indices, :) = [];
        stiffness_matrix(:, constrained_stiffness_matrix_indices) = [];

        nodal_displacements = stiffness_matrix \ global_load_vector;
        all_nodal_displacements(unfixed_indices) = nodal_displacements;
      else
        throw(MException('System:Solve', 'system is not constrained, will result in rigid-body motion'));
      end

      obj.nodal_solution = all_nodal_displacements;
    end

    %* ----- SOLVE ----- *%
    function soln = solve(obj)
      soln = obj.solveNodalDisplacements;
    end

    %* ----- PLOT ----- *%
    function plotUndeformedSystem(obj)
      obj.element_list.plotElements('o--b');
    end
    function plotDeformedSystem(obj, s)
      soln = obj.nodal_solution;
      displaced_nodelist = NodeList;
      for i = 1 : obj.meshed_element_list.getNodeList.len
        full_matrix_indices = nodeListIndexToStiffnessIndices(i);
        current_node_displacements = soln(full_matrix_indices);
        displaced_nodelist.addNodeByLoc( obj.meshed_element_list.getNodeList.getNode(i).getX + current_node_displacements(1) * s, obj.meshed_element_list.getNodeList.getNode(i).getY + current_node_displacements(2) * s);
        displaced_nodelist.getNode(i).setPhi(current_node_displacements(3));
      end
      new_element_list = obj.meshed_element_list.copyWithNewNodes(displaced_nodelist);
      new_element_list.plotElements(':r');
    end
    function plotSystem(obj, s)
      figure
      obj.plotUndeformedSystem;
      obj.plotDeformedSystem(s);
    end
  end
end