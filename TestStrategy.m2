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
    for N in G#Nodes do (
        N#SolutionCount = 1;
        (N#Solutions)#(random(0,d-1)) = true;
    );
    G#EdgeExpectedValues = new MutableList from flatten (
        for E in G#Edges list (
            {{E,E#Node1,(d-1.0)/d}, {E,E#Node2,(d-1.0)/d}}
        )
    )
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

load("ourStrategy.m2")
