load("HomotopyGraphTypes.m2");
load("ourStrategy.m2")

--------------------------------------------------------------------------------
----Given a completed (correspondences all filled in) graph, a fuzzy grph with--
----just one known solution per node, and a number of threads, runs the---------
----strategy and returns useful information about its performance.--------------
--------------------------------------------------------------------------------
simulateRun = method();
simulateRun (ConcreteGraph, FuzzyGraph, ZZ) := (completedGraph, fuzzyGraph, numThreads) -> (
    d := completedGraph#RootCount;
    trackerTimeGenerator := (None -> random(80,120));
    currentTrackerSet := new MutableHashTable from {}; ---set of current trackers
    Data = new MutableHashTable from { ---performance data
        TotalTime => 0,
        TotalPathTracks => 0,
        TracksTillNodeSolved => -1,
        TimeTillNodeSolved => -1,
        TimeIdle => 0,
        GraphIsComplete => false,
        ExistsCompleteNode => false};

    ---function for filling up the tracker list. returns number of new trackers created.
    fillTrackerList := None -> (
        numberAdded := 0;
        while numberAdded <= (numThreads - #currentTrackerSet) do (
            (edgeToTrack, solutionToTrack) := choosePath(fuzzyGraph);
            if instance(edgeToTrack, String) then return numberAdded; ---no trackable paths!
            thisTracker := newPathTracker(edgeToTrack, solutionToTrack, trackerTimeGenerator());
            print (fuzzyGraph === (thisTracker#Edge#Graph));
            currentTrackerSet#thisTracker = 1;
            numberAdded = numberAdded+1;
        );
        numberAdded
    );

    Data#TotalTime = 0;
    while true do (
        --print ("number of nodes according to TestStrategy: "|toString(fuzzyGraph#NumberOfCompleteNodes));
        --print (for N in fuzzyGraph#Nodes list N#SolutionCount);
        --- Loop-stopping checks:
        if fuzzyGraph#NumberOfCompleteNodes == #(fuzzyGraph#Nodes) then (
            ---completed the graph!
            break; 
        );
        if fuzzyGraph#NumberOfCompleteNodes > 0 and Data#ExistsCompleteNode == false then (
            ---completed our first node!
            Data#ExistsCompleteNode = true;
            Data#TimeTillNodeSolved = Data#TotalTime;
            Data#TracksTillNodeSolved = Data#TotalPathTracks
        );
        numberStarted := fillTrackerList(); ----starting (possibly multiple) tracks
        if #currentTrackerSet == 0 then (
            ---Uh oh. Nothing is running and nothing can run.
            ---Maybe means the "solution-refined graph" is a disconnected graph.
            return Data;
        );

        ---pop tracker w/ smallest TimeLeft. Its TimeLeft is how much time has "passed".
        nextFinishedTracker := min keys currentTrackerSet;
        --print (nextFinishedTracker#Edge#Graph === fuzzyGraph);
        remove(currentTrackerSet, nextFinishedTracker);
        timeIncrease := nextFinishedTracker#TimeLeft;

        ---look up correspondence in CompleteGraph, use it for pathFinished.
        edgeInCompleteGraph := completedGraph#DirectedEdges#(nextFinishedTracker#Edge#ID);
        startSol := nextFinishedTracker#StartSolution;
        pathFinished(nextFinishedTracker, edgeInCompleteGraph#Correspondences#startSol);

        ---time-related updates. Idle thread time increases by (# of idle threads - 1)*timeIncrease
        ---since we just popped a tracker off the set.
        Data#TotalTime = Data#TotalTime + timeIncrease;
        Data#TimeIdle = Data#TimeIdle + (numThreads - #currentTrackerSet - 1)*timeIncrease;

        Data#TotalPathTracks = Data#TotalPathTracks + 1;
        for tracker in keys currentTrackerSet do (
            tracker#TimeLeft = tracker#TimeLeft - timeIncrease;
        );
    );

    return Data;
);

nodeIsComplete = method();
nodeIsComplete (HomotopyNode) := (N) -> (N#SolutionCount == N#Graph#RootCount);

(fuzzyGraph, concreteGraph) = setUpGraphs(a -> makeFlowerGraph(3,2,20));
performanceData := simulateRun(concreteGraph, fuzzyGraph, 4);
print peek performanceData;

print fuzzyGraph#NumberOfCompleteNodes;
print (for N in fuzzyGraph#Nodes list N#SolutionCount)
