load("HomotopyGraphTypes.m2")
--------------------------------------------------------------------------------
----Mimics the "path just finished" algorithm from the paper. Given a path------
----that just finished tracking, updates the graph based on the outcome,--------
----maintaining that the nodes all have their correct expected value and that---
----the edges with direction do as well.----------------------------------------
--------------------------------------------------------------------------------
pathFinished = method()
pathFinished (PathTracker, ZZ) := (tracker, newSolutionIndex) -> (
    targetNode := tracker#TargetNode;
    sourceNode := tracker#SourceNode;
    G := targetNode#Graph;
    d := G#RootCount;
    thisEdge := tracker#Edge;

    --update correspondences
    tracker#Edge#CorrespondenceList = append(tracker#Edge#CorrespondenceList, {tracker#StartSolution,newSolutionIndex});

    targetNode#Solutions#newSolutionIndex = true;
    targetNode#SolutionCount = targetNode#SolutionCount+1;

    --update expected values of edges coming into tracker#TargetNode
    TargetNode#ExpectedValue = TargetNode#SolutionCount;
    for E in tracker#TargetNode#Edges do (
        futureCorrespondences := #positions(thisEdge#TrackersOnThisEdge,
            a -> (a#TargetNode === targetNode) and (a#SourceNode === sourceNode));
        newValue := (d-TargetNode#ExpectedValue)/(d - #(E#CorrespondenceList) - futureCorrespondences);
        E#UpdateExpectedValue(targetNode, newValue);
    );
);

--------------------------------------------------------------------------------
----I don`t love the code repitition here, but this function loops through the--
----edges_with_directions and finds the set of them with maximal expected-------
----value. Currently, it just takes the first one it comes to, but in the-------
----future we could try and pick between ties in some other way, if we want.----
--------------------------------------------------------------------------------
choosePath = method();
choosePath (FuzzyGraph) := (G) -> (
    maxExpectedVal := 0;
    maxEdgesDirections := new MutableList from {};
    for E in G#Edges do (
        if E#LeftExpectedValue > maxExpectedVal then (
            maxExpectedVal = E#LeftExpectedValue;
            maxEdgesDirection = new MutableList from {{E,E#Node1}};
        ) else if E#LeftExpectedValue == maxExpectedVal then (
            maxEdgesDirection = append(maxEdgesDirection, {E,E#Node1});
        );
        if E#RightExpectedValue > maxExpectedVal then (
            maxExpectedVal = E#RightExpectedValue;
            maxEdgesDirection = new MutableList from {{E,E#Node2}};
        ) else if E#RightExpectedValue == maxExpectedVal then (
            maxEdgesDirection = append(maxEdgesDirection, {E,E#Node2});
        );
    );
    maxEdgesDirections#0;
);
