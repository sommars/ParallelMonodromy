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
        SolutionCount => 0
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
        CorrespondenceList => new MutableList from {}
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

G = makeFlowerGraph (3,3,20);