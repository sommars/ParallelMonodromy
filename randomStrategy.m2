load("ourStrategy.m2")

pathFinishedRandom = method()
pathFinishedRandom (PathTracker, ZZ) := (tracker, newSolutionIndex) -> (
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
        if destNode#SolutionCount == G#RootCount then (
            G#NumberOfCompleteNodes = G#NumberOfCompleteNodes + 1;
        );
    );
    remove(thisDirectedEdge#OtherEdge#TrackableSolutions, newSolutionIndex);
    thisDirectedEdge#TrackerCount = thisDirectedEdge#TrackerCount - 1;
);

--------------------------------------------------------------------------------
---Loops through the edges_with_directions and finds the set of them with-------
---maximal expected value. Currently, it just takes the first one it comes to,--
---but in the future we could try and pick between ties in some other way.------
--------------------------------------------------------------------------------
choosePathRandom = method();
choosePathRandom (FuzzyGraph) := (G) -> (
    CandidateEdges := new MutableHashTable from {};
    for E in G#DirectedEdges do (
        if #(E#TrackableSolutions)==0 then
            continue;
        CandidateEdges#E = 1;
    );
    
    if #CandidateEdges==0 then
        return ("no paths available",0);
        
    index := random(0,#(CandidateEdges)-1);
    edgeToTrack := (keys(CandidateEdges))#index;

    edgeToTrack#TrackerCount = edgeToTrack#TrackerCount + 1;
    solutionToTrack := (keys(edgeToTrack#TrackableSolutions))#0;
    remove(edgeToTrack#TrackableSolutions, solutionToTrack);
    (edgeToTrack, solutionToTrack)
);
