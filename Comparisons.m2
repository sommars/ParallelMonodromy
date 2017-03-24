load("TestStrategy.m2");
{*
        RootCount => d, 
        TotalTime => 0,
        TotalPathTracks => 0,
        TracksTillNodeSolved => -1,
        TimeTillNodeSolved => -1,
        TimeIdle => 0,
        CorrespondenceCollisions => 0;
        GraphIsComplete => false,
        ExistsCompleteNode => false
*}
runComparison = method(Options => {UseRandomStrategy => false});
runComparison (Function, ZZ, ZZ) := o -> (graphCreator, numThreads, numTrials) -> (
    toReturn := new MutableHashTable from {
        GraphIsComplete => {},
        TotalTime =>  {},
        TotalPathTracks =>  {},
        CorrespondenceCollisions => {},
        TimeIdle =>  {}};
    for i in 0..(numTrials-1) list (
        setRandomSeed(i);
        (fuzzyGraph, concreteGraph) = setUpGraphs(graphCreator);
        performanceData := simulateRun(concreteGraph, fuzzyGraph, numThreads, UseRandomStrategy => o.UseRandomStrategy);
        --performanceData#TotalPathTracks
        --performanceData#TimeIdle
        for k in keys toReturn do (
            toReturn#k = append(toReturn#k, performanceData#k);
        );
    );
    << "RandomStrategyUsed = " << o.UseRandomStrategy << endl;
    print (peek toReturn);
);
numThreads := 8;
numTrials := 5;
rootCount := 5000;
petalCount := 6;
edgeCount := 3;
time runComparison((a -> makeFlowerGraph(petalCount,edgeCount,rootCount,a)), numThreads, numTrials, UseRandomStrategy => true)
time runComparison((a -> makeFlowerGraph(petalCount,edgeCount,rootCount,a)), numThreads, numTrials, UseRandomStrategy => false)
