HomotopyNode = new Type of MutableHashTable
HomotopyEdge = new Type of MutableHashTable
HomotopyGraph = new Type of MutableHashTable

ConcreteGraph = new Type of HomotopyGraph
FuzzyGraph = new Type of ConcreteGraph
HomotopyDirectedEdge = new Type of HomotopyEdge

BasicList | BasicList := (l1,l2) -> new (class l1) from (toList(l1)|toList(l2));

newGraph = method()
newGraph (ZZ, Type) := (InputRootCount, HomotopyGraphType) -> (
    G := new HomotopyGraphType from {
        RootCount => InputRootCount,
        Nodes => new MutableList from {},
        DirectedEdges => new MutableList from {},
        HalfTheEdges => new MutableList from {},
        NumberOfCompleteNodes => 0
    };
    G
);

addNode = method()
addNode (HomotopyGraph) := (G) -> (
    N := new HomotopyNode from {
        Graph => G,
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
        Correspondences => new MutableHashTable from {},
        ID => #(G#DirectedEdges)
    };
    E2 := new HomotopyDirectedEdge from {
        SourceNode => N2,
        TargetNode => N1,
        Graph => G,
        Correspondences => new MutableHashTable from {},
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
makeFlowerGraph (ZZ, ZZ, ZZ, Type) := (PetalCount, EdgeCount, RootCount, HomotopyGraphType) -> (
    G := newGraph(RootCount, HomotopyGraphType);
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
        knownSolution := (random(0,d-1));
        (N#Solutions)#knownSolution = true;
        N#ExpectedValue = 1;
        for E in N#OutgoingEdges do (
            E#TrackableSolutions = new MutableHashTable from {knownSolution => 0};
        );
    );
    for E in G#DirectedEdges do (    -----making edges fuzzy----
        E#ExpectedValue = (d-1)/d;
        E#TrackerCount = 0;
    );
    G
);

--------------------------------------------------------------------------------
----From a HomotopyGraph, fills in the correspondences randomly and sets--------
----node data so that the graph has been "solved".------------------------------
--------------------------------------------------------------------------------
completifyGraph = method() 
completifyGraph (HomotopyGraph) := (G) -> ( 
    G#NumberOfCompleteNodes = #(G#Nodes);
    d := G#RootCount;
    for N in G#Nodes do (
        N#SolutionCount = d;
        for i in 0..(d-1) do N#Solutions#i = true;
    );
    for E in G#HalfTheEdges do (
        shuffledList := random toList (0..(d-1));
        shuffledList = new MutableHashTable from flatten for i in 0..d-1 list {i => shuffledList#i};
        E#Correspondences = shuffledList;
        E#OtherEdge#Correspondences = new MutableHashTable from flatten apply(keys shuffledList, a->{shuffledList#a => a});
    );
    G
);

setUpGraphs = method()
setUpGraphs (Function) := (graphCreator) -> (
    (fuzzifyGraph graphCreator(FuzzyGraph), completifyGraph graphCreator(ConcreteGraph))
);

--------------------------------------------------------------------------------
PathTracker = new Type of MutableHashTable;
newPathTracker = method()
newPathTracker (HomotopyDirectedEdge, ZZ, ZZ) := (iEdge, iStartSolution, iTimeLeft) -> (
    new PathTracker from {
        Edge => iEdge,
        StartSolution => iStartSolution,
        TimeLeft => iTimeLeft
    }
);

----so we can take the "min" of a tracker list to get the next one to finish----
PathTracker ? PathTracker := (t1, t2) -> return ((t1#TimeLeft) ? (t2#TimeLeft));

--peek newPathTracker(new HomotopyDirectedEdge,4)
