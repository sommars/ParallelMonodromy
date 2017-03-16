load("HomotopyGraphTypes.m2")
pathFinished = method()
pathFinished (PathTracker, ZZ) := (tracker, newSolutionIndex) -> (
    targetNode := tracker # TargetNode;
    sourceNode := tracker # SourceNode;
    G := targetNode # Graph;
    d := G # RootCount;
    thisEdge := tracker # Edge;

    --update correspondences
    corList := tracker # Edge # CorrespondenceList;
    corList = append(corList,{tracker # StartSolution,newSolutionIndex});

    targetNode # Solutions # newSolutionIndex = true;
    targetNode # SolutionCount = targetNode # SolutionCount+1;

    --update expected values of edges coming into tracker # TargetNode
    TargetNode # ExpectedValue = TargetNode # SolutionCount;
    for E in tracker # TargetNode # Edges do (
        futureCorrespondences := #positions(thisEdge # TrackersOnThisEdge,
            a -> (a # TargetNode === targetNode) and (a # SourceNode === sourceNode));
        newValue := (d-TargetNode # ExpectedValue)/(d - #(E#CorrespondenceList) - futureCorrespondences);
        E # UpdateExpectedValue(targetNode, newValue);
    );

);
