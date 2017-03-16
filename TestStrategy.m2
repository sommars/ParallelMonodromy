load("HomotopyGraphTypes.m2");
setUpGraphs = method()
setUpGraphs (Function) := (graphCreator) -> (
    fuzzyGraph := graphCreator();
    initializeFuzzyGraph graphCreator();
    concreteGraph := graphCreator();
    initializeCompletedGraph graphCreator();
    (fuzzyGraph,concreteGraph)
);

initializeFuzzyGraph = method()
initializeFuzzyGraph (HomotopyGraph) := (G) -> (
    d := G#RootCount;
    G#EdgesBeingTracked = new MutableList from {};
    for N in G#Nodes do (    -----making nodes fuzzy----
        N#SolutionCount = 1;
        (N#Solutions)#(random(0,d-1)) = true;
        N#ExpectedValue = 0;
    );
    for E in G#Edges do (    -----making edges fuzzy----
        E#UpdateExpectedValue = 
            (targetNode,value) -> (
                assert ((targetNode === E#Node1) or (targetNode === E#Node2));
                if targetNode === E#Node2 then E#RightExpectedValue = value
                else E#LeftExpectedValue = value;
            );
        E#UpdateExpectedValue(E#Node1,(d-1.0)/d);
        E#UpdateExpectedValue(E#Node2,(d-1.0)/d);
        --E#LeftExpectedValue = (d-1.0)/d
        --E#RightExpectedValue = (d-1.0)/d
        E#TrackersOnThisEdge = new MutableList from {};
    );
);

initializeCompletedGraph = method()
initializeCompletedGraph (HomotopyGraph) := (G) -> (
    d := G#RootCount;
    for E in G#Edges do (
        shuffledList := random toList (0..(d-1));
        E#CorrespondenceList = for i in 0..d-1 list {i,shuffledList#i};
    );
);

(fuzzyGraph, concreteGraph) = setUpGraphs(a -> makeFlowerGraph(3,3,20));
peek fuzzyGraph
load("ourStrategy.m2")

