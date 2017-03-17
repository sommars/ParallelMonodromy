load("HomotopyGraphTypes.m2");
load("ourStrategy.m2")

--------------------------------------------------------------------------------
----Given a completed (correspondences all filled in) graph, a fuzzy grph with--
----just one known solution per node, and a number of threads, runs the---------
----strategy and returns useful information about its performance.--------------
--------------------------------------------------------------------------------
simulateRun = method();
simulateRun (ConcreteGraph, FuzzyGraph, ZZ) := (completedGraph, fuzzyGraph, numThreads) -> (
    totalTime := 0;
    for i in 1..numThreads do (
        thisT := choosePath(FuzzyGraph);
    );
    (totalTime, totalPathTracks, tracksTillNodeSolved)
);
