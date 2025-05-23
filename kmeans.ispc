export uniform double dist_ispc(uniform double x[], uniform double y[], uniform int nDim)
{
    varying double local_accum = 0;
    foreach (i = 0 ... nDim) { 
        double diff = x[i] - y[i];
        local_accum += diff * diff;
    }
    return reduce_add(local_accum);
}

task void dist_ispc_task(uniform double x[], uniform double y[], uniform int worksPerTask, uniform int nDim, uniform double partialResult[])
{
    uniform int start = worksPerTask * taskIndex;
    uniform int end = start + worksPerTask;
    varying double local_accum = 0;
    // print("start = %\n", start);
    // print("end = %\n", end);
    // print("worksPerTask = %\n", worksPerTask);
    foreach (i = start ... end) { 
        double diff = x[i] - y[i];
        local_accum += diff * diff;
    }
    
    partialResult[taskIndex] = reduce_add(local_accum);
    // print("partialResult = %\n", partialResult[taskIndex]);
}

export uniform double dist_ispc_withtasks(uniform double x[], uniform double y[], uniform int nDim)
{
    uniform int numTask = 10;

    uniform double partialResult[10];

    uniform int worksPerTask = nDim / numTask; // create 10 tasks

    launch[numTask] dist_ispc_task(x, y, worksPerTask, nDim, partialResult);

    sync;

    uniform double accum = 0;
    for (uniform int i = 0; i < numTask; i++) {
        accum += partialResult[i];
    }
    return accum;
}