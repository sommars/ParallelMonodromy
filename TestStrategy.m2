load("HomotopyGraphTypes.m2");
load("OurStrategy.m2");
load("randomStrategy.m2");

--------------------------------------------------------------------------------
----Given a completed (correspondences all filled in) graph, a fuzzy grph with--
----just one known solution per node, and a number of threads, runs the---------
----strategy and returns useful information about its performance.--------------
--------------------------------------------------------------------------------
----General idea: we maintain a set of trackers that are "currently" running.---
----Each has a time until completion. We pop the smallest one, increment the----
----total runtime by its timeLeft, and update fuzzyGraph based on what the------
----tracker would have found, which we look up in completedGraph. We then-------
----refill the tracker set. All the while, we maintain information about the----
----performance of the method in the Data hashtable, which we return at the-----
----end.------------------------------------------------------------------------
--------------------------------------------------------------------------------
simulateRun = method(Options => {UseRandomStrategy => false});
simulateRun (ConcreteGraph, FuzzyGraph, ZZ) := o -> (completedGraph, fuzzyGraph, numThreads) -> (

    d := completedGraph#RootCount;
    trackerTimeGenerator := (None -> random(80,120));
    currentTrackerSet := new MutableHashTable from {}; ---set of current trackers
    Data = new MutableHashTable from { ---performance data
        RootCount => d,
        TotalTime => 0,
        TotalPathTracks => 0,
        TracksTillNodeSolved => -1,
        TimeTillNodeSolved => -1,
        TimeIdle => 0,
        CorrespondenceCollisions => 0, --i.e. # of times an edge found a preexisting corr.
                                       --Can happen when two threads track in opposite directions.
        GraphIsComplete => false,
        ExistsCompleteNode => false};
    ---function for filling up the tracker list. returns the number of new trackers created.
    fillTrackerList := None -> (
        numberAdded := 0;
        emptySlots := (numThreads - #currentTrackerSet);
        while numberAdded < emptySlots do (
            if o.UseRandomStrategy then (
                (edgeToTrack, solutionToTrack) := choosePathRandom(fuzzyGraph);
            ) else (
                (edgeToTrack, solutionToTrack) = choosePath(fuzzyGraph);
            );
            if instance(edgeToTrack, String) then return numberAdded; ---no trackable paths!
            thisTracker := newPathTracker(edgeToTrack, solutionToTrack, trackerTimeGenerator());
            currentTrackerSet#thisTracker = 1;
            numberAdded = numberAdded+1;
        );
        numberAdded
    );

    Data#TotalTime = 0;
    while true do (
        --- Loop-stopping checks:
        if fuzzyGraph#NumberOfCompleteNodes > 0 and Data#ExistsCompleteNode == false then (
            ---completed our first node!
            Data#ExistsCompleteNode = true;
            Data#TimeTillNodeSolved = Data#TotalTime;
            Data#TracksTillNodeSolved = Data#TotalPathTracks;
            return Data;
        );
        if fuzzyGraph#NumberOfCompleteNodes == #(fuzzyGraph#Nodes) then (
            ---completed the graph!
            Data#GraphIsComplete = true;
            print "completed the graph!";
            break; 
        );

        numberStarted := fillTrackerList(); ----starting (possibly multiple) tracks
        
        if #currentTrackerSet == 0 then (
            ---Uh oh. Nothing is running and nothing can run.
            ---Maybe means the "solution-refined graph" is a disconnected graph.
            return Data;
        );

        ---pop tracker w/ smallest TimeLeft. Its TimeLeft is how much time has "passed".
        nextFinishedTracker := min keys currentTrackerSet;
        remove(currentTrackerSet, nextFinishedTracker);
        timeIncrease := nextFinishedTracker#TimeLeft;

        ---look up correspondence in CompleteGraph, use it for pathFinished.
        edgeInCompleteGraph := completedGraph#DirectedEdges#(nextFinishedTracker#Edge#ID);
        startSol := nextFinishedTracker#StartSolution;
        if nextFinishedTracker#Edge#Correspondences#?(nextFinishedTracker#StartSolution) then (
            Data#CorrespondenceCollisions = Data#CorrespondenceCollisions + 1;
        );

        if o.UseRandomStrategy then
            pathFinishedRandom(nextFinishedTracker, edgeInCompleteGraph#Correspondences#startSol)
        else
            pathFinished(nextFinishedTracker, edgeInCompleteGraph#Correspondences#startSol);

        ---time-related updates. Idle thread time increases by (# of idle threads - 1)*timeIncrease
        ---since we just popped a tracker off the set.
        Data#TotalTime = Data#TotalTime + timeIncrease;
        idleThreadCount := (numThreads - #currentTrackerSet - 1);
        if idleThreadCount>0 then (
            Data#TimeIdle = (Data#TimeIdle) + idleThreadCount*timeIncrease;
        );

        Data#TotalPathTracks = Data#TotalPathTracks + 1;

        ---"timeIncrease" time has passed, so we subtract it from the timeLeft of all trackers.
        for tracker in keys currentTrackerSet do (
            tracker#TimeLeft = tracker#TimeLeft - timeIncrease;
        );
    );
    return Data;
);

{*
nodeIsComplete = method();
nodeIsComplete (HomotopyNode) := (N) -> (N#SolutionCount == N#Graph#RootCount);

(fuzzyGraph, concreteGraph) = setUpGraphs(a -> makeFlowerGraph(3,2,200,a));
performanceData := simulateRun(concreteGraph, fuzzyGraph, 8);
print peek performanceData;

print fuzzyGraph#NumberOfCompleteNodes;
print (for N in fuzzyGraph#Nodes list N#SolutionCount)
*}
