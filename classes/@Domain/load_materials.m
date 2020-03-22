function load_materials(obj, project_dir)
    % Reads the materials file. Called from readFromFile

    materialsFileName = [project_dir,'/materials.xml'];
    xml_root = parseXML(materialsFileName);

    for xml_node = xml_root.Children
        if(strcmp(xml_node.Name,'material'))
            obj.new_material(xml_node.Attributes);
        end
    end

end