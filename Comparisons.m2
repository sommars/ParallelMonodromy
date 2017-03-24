load("TestStrategy.m2");
---Aggregates data returned by simulateRun.
runComparison = method(Options => {UseRandomStrategy => false});
runComparison (Function, ZZ, ZZ) := o -> (graphCreator, numThreads, numTrials) -> (
    ---The keys of interest. If you want data on something else returned by 
    ---simulateRun, simply add its key here.
    toReturn := new MutableHashTable from {
        GraphIsComplete => {},
        TotalTime =>  {},
        TotalPathTracks =>  {},
        CorrespondenceCollisions => {},
        TimeIdle =>  {}};
    for i in 0..(numTrials-1) list (
        setRandomSeed(i); --for reproducibility.
        (fuzzyGraph, concreteGraph) = setUpGraphs(graphCreator);
        performanceData := simulateRun(concreteGraph, fuzzyGraph, numThreads, UseRandomStrategy => o.UseRandomStrategy);
        for k in keys toReturn do (
            toReturn#k = append(toReturn#k, performanceData#k);
        );
    );
    << "RandomStrategyUsed = " << o.UseRandomStrategy << endl;
    print (peek toReturn);
);

numThreads := 7;
numTrials := 5;
rootCount := 1000;
petalCount := 2;
edgeCount := 2;
graphStrategy := (a -> makeFlowerGraph(petalCount,edgeCount,rootCount,a));
time runComparison(graphStrategy, numThreads, numTrials, UseRandomStrategy => true)
time runComparison(graphStrategy, numThreads, numTrials, UseRandomStrategy => false)
time runComparison(graphStrategy, 1, numTrials, UseRandomStrategy => false)
