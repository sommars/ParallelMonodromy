load("TestStrategy.m2");
{*
        RootCount => d, 
        TotalTime => 0,
        TotalPathTracks => 0,
        TracksTillNodeSolved => -1,
        TimeTillNodeSolved => -1,
        TimeIdle => 0,
        GraphIsComplete => false,
        ExistsCompleteNode => false
*}
runComparison = method();
runComparison (Function, ZZ, ZZ) := (graphCreator, numberThreads, numberTrials) -> (
    for i in 1..numberTrials list (
        setRandomSeed(i);
        (fuzzyGraph, concreteGraph) = setUpGraphs(graphCreator);
        performanceData := simulateRun(concreteGraph, fuzzyGraph, numberThreads);
        --performanceData#TotalPathTracks
        performanceData#TimeIdle
    )
);
time runComparison((a -> makeFlowerGraph(3,2,2000,a)), 8, 5)
time runComparison((a -> makeFlowerGraph(3,2,3000,a)), 8, 5)
time runComparison((a -> makeFlowerGraph(3,2,4000,a)), 8, 5)
