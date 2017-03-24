# ParallelMonodromy

## File overview:
### Comparisons.m2
File for actually running tests. You can set a number of trials and accumulate
data about all the runs.

### HomotopyGraphTypes.m2
Defines concrete and fuzzy graph types, as in our paper. Methods for
constructing graphs and graph elements. Also defines and constructs the
PathTracker type.

### OurStrategy.m2
Defines the functions (from our paper) to choose a path to track and keep the
graph data (expected values, etc.) up to date.

### randomStrategy.m2
Defines functions to do a random edge selection strategy, for comparison vs. our
strategy.

### TestStrategy.m2
Simulates a run of our algorithm, keeping track of number of path tracks, time
taken, etc.
