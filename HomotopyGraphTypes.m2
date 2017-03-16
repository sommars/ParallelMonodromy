HomotopyNode = new Type of MutableHashTable
HomotopyEdge = new Type of MutableHashTable
HomotopyGraph = new Type of MutableHashTable

ConcreteGraph = new Type of HomotopyGraph
FuzzyGraph = new Type of ConcreteGraph

newGraph = method()
newGraph (ZZ) := (InputRootCount) -> (
    G := new HomotopyGraph from {
        RootCount => InputRootCount,
        Nodes => new MutableList from {},
        Edges => new MutableList from {}
    };
    G
);

addNode = method()
addNode (HomotopyGraph) := (G) -> (
    N := new HomotopyNode from {
        Edges => new MutableList from {},
        Solutions => new MutableList from (for i in 1..G#RootCount list false),
        SolutionCount => 0,
        ID => #(G#Nodes)
    };
    G#Nodes = append(G#Nodes, N);
    N
);

addEdge = method()
addEdge (HomotopyGraph, HomotopyNode, HomotopyNode) := (G, N1, N2) -> (
    E := new HomotopyEdge from {
        Node1 => N1,
        Node2 => N2,
        Graph => G,
        CorrespondenceList => new MutableList from {},
        ID => #(G#Edges)
    };
    N1#Edges = append(N1#Edges, E);
    N2#Edges = append(N2#Edges, E);
    G#Edges = append(G#Edges, E);
    E
);

makeFlowerGraph = method()
makeFlowerGraph (ZZ, ZZ, ZZ) := (PetalCount, EdgeCount, RootCount) -> (
    G := newGraph(RootCount);
    N := addNode(G);
    for i in 1..PetalCount do (
        newNode := addNode(G);
        apply(EdgeCount, a->addEdge(G,N,newNode));
    );
    G
);

setUpGraphs = method()
setUpGraphs (Function) := (graphCreator) -> (
    (fuzzifyGraph graphCreator(), concretifyGraph graphCreator())
);

fuzzifyGraph = method()
fuzzifyGraph (HomotopyGraph) := (G) -> (
    d := G#RootCount;
    G#EdgesBeingTracked = new MutableList from {};
    for N in G#Nodes do (    -----making nodes fuzzy----
        N#SolutionCount = 1;
        (N#Solutions)#(random(0,d-1)) = true;
        N#ExpectedValue = 1;
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
        E#TrackersOnThisEdge = new MutableList from {};
    );
    new FuzzyGraph from G
);

concretifyGraph = method() 
concretifyGraph (HomotopyGraph) := (G) -> ( 
    d := G#RootCount;
    for E in G#Edges do (
        shuffledList := random toList (0..(d-1));
        E#CorrespondenceList = for i in 0..d-1 list {i,shuffledList#i};
    );
    new ConcreteGraph from G
);

--(fuzzyGraph, concreteGraph) = setUpGraphs(a -> makeFlowerGraph(3,3,20));
--print class concreteGraph

--------------------------------------------------------------------------------
PathTracker = new Type of MutableHashTable;
newPathTracker = method()
newPathTracker (ZZ, HomotopyEdge, ZZ, HomotopyNode) := (iTimeTillComplete, iEdge, iStartSolution, iTargetNode) -> (
    new PathTracker from {
        TimeTillComplete => iTimeTillComplete,
        Edge => iEdge,
        SourceNode => if iTargetNode === iEdge#Node1 then iEdge#Node2 else iEdge#Node1,
        TargetNode => iTargetNode,
        StartSolution => iStartSolution
    }
);

--peek newPathTracker(3,new HomotopyEdge,4,new HomotopyNode)
