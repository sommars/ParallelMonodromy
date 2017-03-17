HomotopyNode = new Type of MutableHashTable
HomotopyEdge = new Type of MutableHashTable
HomotopyGraph = new Type of MutableHashTable

ConcreteGraph = new Type of HomotopyGraph
FuzzyGraph = new Type of ConcreteGraph
HomotopyDirectedEdge = new Type of HomotopyEdge

BasicList | BasicList := (l1,l2) -> new (class l1) from (toList(l1)|toList(l2));

newGraph = method()
newGraph (ZZ) := (InputRootCount) -> (
    G := new HomotopyGraph from {
        RootCount => InputRootCount,
        Nodes => new MutableList from {},
        DirectedEdges => new MutableList from {},
        HalfTheEdges => new MutableList from {}
    };
    G
);

addNode = method()
addNode (HomotopyGraph) := (G) -> (
    N := new HomotopyNode from {
        OutgoingEdges => new MutableList from {},
        IncomingEdges => new MutableList from {},
        Solutions => new MutableList from (for i in 1..G#RootCount list false),
        SolutionCount => 0,
        ID => #(G#Nodes)
    };
    G#Nodes = append(G#Nodes, N);
    N
);

--------------------------------------------------------------------------------
--- N1 ===E1==> N2 -------------------------------------------------------------
--- N1 <==E2=== N2 -------------------------------------------------------------
--------------------------------------------------------------------------------
addEdge = method()
addEdge (HomotopyGraph, HomotopyNode, HomotopyNode) := (G, N1, N2) -> (
    E1 := new HomotopyDirectedEdge from {
        SourceNode => N1,
        TargetNode => N2,
        Graph => G,
        CorrespondenceList => new MutableList from {},
        ID => #(G#DirectedEdges)
    };
    E2 := new HomotopyDirectedEdge from {
        SourceNode => N2,
        TargetNode => N1,
        Graph => G,
        CorrespondenceList => new MutableList from {},
        ID => #(G#DirectedEdges) + 1
    };
    E1#OtherEdge = E2;
    E2#OtherEdge = E1;
    N1#OutgoingEdges = append(N1#OutgoingEdges, E1);
    N2#OutgoingEdges = append(N2#OutgoingEdges, E2);
    N2#IncomingEdges = append(N2#IncomingEdges, E1);
    N1#IncomingEdges = append(N1#IncomingEdges, E2);
    G#DirectedEdges = G#DirectedEdges|{E1,E2};
    G#HalfTheEdges = append(G#HalfTheEdges, E1);
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

--------------------------------------------------------------------------------
----From a HomotopyGraph, makes it into a FuzzyGraph. Randomly chooses a--------
----solution at each node to "know", without knowing any correspondences,-------
----and sets the expected values accordingly.-----------------------------------
--------------------------------------------------------------------------------
fuzzifyGraph = method()
fuzzifyGraph (HomotopyGraph) := (G) -> (
    d := G#RootCount;
    G#EdgesBeingTracked = new MutableList from {};
    for N in G#Nodes do (    -----making nodes fuzzy----
        N#SolutionCount = 1;
        (N#Solutions)#(random(0,d-1)) = true;
        N#ExpectedValue = 1;
    );
    for E in G#DirectedEdges do (    -----making edges fuzzy----
        E#ExpectedValue = (d-1.0)/d;
        E#TrackersOnThisEdge = new MutableList from {};
        E#NumberTrackableEdges = 1;
    );
    {*
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
    ); *}
    new FuzzyGraph from G
);

--------------------------------------------------------------------------------
----From a HomotopyGraph, fills in the correspondences randomly and sets--------
----node data so that the graph has been "solved".------------------------------
--------------------------------------------------------------------------------
completifyGraph = method() 
completifyGraph (HomotopyGraph) := (G) -> ( 
    d := G#RootCount;
    for N in G#Nodes do (
        N#SolutionCount = d;
        for i in 0..(d-1) do N#Solutions#i = true;
    );
    for E in G#HalfTheEdges do (
        shuffledList := random toList (0..(d-1));
        shuffledList = for i in 0..d-1 list {i,shuffledList#i};
        E#CorrespondenceList = shuffledList;
        E#OtherEdge#CorrespondenceList = sort apply(shuffledList,a->{a#1,a#0});
    );
    new ConcreteGraph from G
);

setUpGraphs = method()
setUpGraphs (Function) := (graphCreator) -> (
    (fuzzifyGraph graphCreator(), completifyGraph graphCreator())
);

--(fuzzyGraph, concreteGraph) = setUpGraphs(a -> makeFlowerGraph(3,3,20));

--------------------------------------------------------------------------------
PathTracker = new Type of MutableHashTable;
newPathTracker = method()
newPathTracker (HomotopyDirectedEdge, ZZ) := (iEdge, iStartSolution) -> (
    new PathTracker from {
        Edge => iEdge,
        StartSolution => iStartSolution
    }
);

--peek newPathTracker(new HomotopyDirectedEdge,4)
