function store_cache(obj, seq)
    cacheFileName = [obj.project_dir,'/.cache'];
    meshFileName = [obj.project_dir,'/mesh.fmsh'];
    materialsFileName = [obj.project_dir,'/materials.xml'];
    
    cacheFile = fopen(cacheFileName,'w+');
    if cacheFile < 1
        warning('Failed to cache data');
        return
    end

    mesh_check_sum = Simulink.getFileChecksum(meshFileName);
    mats_check_sum = Simulink.getFileChecksum(materialsFileName);
    
    fprintf(cacheFile, '%s\n', mesh_check_sum);
    fprintf(cacheFile, '%s\n', mats_check_sum);
    fprintf(cacheFile, '%d\n', obj.problem_type);
    fprintf(cacheFile, '%d\n', obj.integrationDegree);
    
    for i=1:seq.K.n_entries
        fprintf(cacheFile,'%5d\t%5d\t%15e\n',seq.K.cols(i), seq.K.rows(i), seq.K.vals(i));
    end
    fprintf(cacheFile, 'EOF');
    
    fclose(cacheFile);
end