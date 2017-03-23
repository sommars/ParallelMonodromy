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
    toReturn := new MutableHashTable from {
        GraphIsComplete => {},
        TotalTime =>  {},
        TotalPathTracks =>  {},
        TimeIdle =>  {}};
    for i in 0..(numberTrials-1) list (
        setRandomSeed(i);
        (fuzzyGraph, concreteGraph) = setUpGraphs(graphCreator);
        performanceData := simulateRun(concreteGraph, fuzzyGraph, numberThreads);
        --performanceData#TotalPathTracks
        --performanceData#TimeIdle
        for k in keys toReturn do (
            toReturn#k = append(toReturn#k, performanceData#k);
        );
    );
    print (peek toReturn);
);
numberThreads := 8;
numberTrials := 5;
time runComparison((a -> makeFlowerGraph(3,2,2000,a)), numberThreads, numberTrials)
--time runComparison((a -> makeFlowerGraph(3,2,3000,a)), 8, 5)
--time runComparison((a -> makeFlowerGraph(3,2,4000,a)), 8, 5)
