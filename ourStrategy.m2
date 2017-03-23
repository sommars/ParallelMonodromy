load("HomotopyGraphTypes.m2")
--------------------------------------------------------------------------------
----Mimics the "path just finished" algorithm from the paper. Given a path------
----that just finished tracking, updates the graph based on the outcome,--------
----maintaining that the nodes all have their correct expected value and that---
----the edges with direction do as well.----------------------------------------
--------------------------------------------------------------------------------
pathFinished = method()
pathFinished (PathTracker, ZZ) := (tracker, newSolutionIndex) -> (
    thisDirectedEdge := tracker#Edge;
    G := thisDirectedEdge#Graph;
    destNode := thisDirectedEdge#TargetNode;
    sourceNode := thisDirectedEdge#SourceNode;

    ----update correspondences----
    newCorr := {tracker#StartSolution,newSolutionIndex};
    thisDirectedEdge#Correspondences#(newCorr#0) = newCorr#1;
    thisDirectedEdge#OtherEdge#Correspondences#(newCorr#1) = newCorr#0;
    if destNode#Solutions#newSolutionIndex == false then (  ---we found a new solution
        destNode#Solutions#newSolutionIndex = true;
        destNode#SolutionCount = destNode#SolutionCount+1;
        for E in destNode#OutgoingEdges do (
            E#TrackableSolutions#newSolutionIndex = 1;
        );
        if destNode#SolutionCount == G#RootCount then 
            G#NumberOfCompleteNodes = G#NumberOfCompleteNodes + 1;
    );
    remove(thisDirectedEdge#OtherEdge#TrackableSolutions, newSolutionIndex);
    thisDirectedEdge#TrackerCount = thisDirectedEdge#TrackerCount - 1;
    recomputeExpectedValues(destNode);
);

--------------------------------------------------------------------------------
---Loops through the edges_with_directions and finds the set of them with-------
---maximal expected value. Currently, it just takes the first one it comes to,--
---but in the future we could try and pick between ties in some other way.------
--------------------------------------------------------------------------------
choosePath = method();
choosePath (FuzzyGraph) := (G) -> (
    maxExpectedVal := 0;
    d := G#RootCount;
    maxEdgeList := new MutableList from {};
    for E in G#DirectedEdges do (
        if #(E#TrackableSolutions)==0 then continue;
        if E#ExpectedValue > maxExpectedVal then (
            maxExpectedVal = E#ExpectedValue;
            maxEdgeList = new MutableList from {E};
        ) else if E#ExpectedValue == maxExpectedVal then (
            maxEdgeList = append(maxEdgeList, E);
        );
    );
    if #maxEdgeList==0 then return ("no paths available",0);
    edgeToTrack := maxEdgeList#0;
    N := edgeToTrack#TargetNode;
    edgeToTrack#TrackerCount = edgeToTrack#TrackerCount + 1;
    N#ExpectedValue = N#ExpectedValue + maxExpectedVal;
    ---update expected values of edges coming into tracker#TargetNode
    ---need some criteria for setting this to 0. Like, if 
    for E in N#IncomingEdges do (
        if (d - E#TrackerCount - #(E#Correspondences)) == 0 then (
            E#ExpectedValue = 0;
        ) else (
            E#ExpectedValue = (d - N#ExpectedValue)/(d - E#TrackerCount - #(E#Correspondences));
        );
    );
    solutionToTrack := (keys(edgeToTrack#TrackableSolutions))#0;
    remove(edgeToTrack#TrackableSolutions, solutionToTrack);
    (edgeToTrack, solutionToTrack)
);

recomputeExpectedValues = method()
recomputeExpectedValues (HomotopyNode) := (N) -> (
    d := N#Graph#RootCount;
    ----Update E(v^A) at the dest node v----
    ----Uses Prop 2.3 and Prop 2.4-----
    N#ExpectedValue = N#SolutionCount;
    for E in N#IncomingEdges do (
        if (d - E#TrackerCount - #(E#Correspondences)) == 0 then continue;
        currentTrackerCount := E#TrackerCount;
        N#ExpectedValue = N#ExpectedValue + 
            currentTrackerCount*(d - N#ExpectedValue)/(d - currentTrackerCount - #(E#Correspondences));
    );
    ----update expected values of edges coming into tracker#TargetNode-----
    for E in N#IncomingEdges do (
        if (d - E#TrackerCount - #(E#Correspondences)) == 0 then (
            E#ExpectedValue = 0;
        ) else (
            E#ExpectedValue = (d - N#ExpectedValue)/(d - E#TrackerCount - #(E#Correspondences));
        );
    );
);
