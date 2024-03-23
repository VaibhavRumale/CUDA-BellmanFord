#include <iostream>
#include <fstream>
#include <cstdlib>
#include <ctime>

#define V 1000 // Number of vertices
#define MAX_WEIGHT 100 // Maximum weight of edges

int main() {
    std::ofstream outFile("large_graph.txt");
    if (!outFile) {
        std::cerr << "Error creating output file." << std::endl;
        return 1;
    }

    srand(time(NULL)); // Seed for random weight generation

    // Generate edges with random weights
    for (int i = 0; i < V; ++i) {
        for (int j = i + 1; j < V; ++j) {
            int weight = rand() % MAX_WEIGHT + 1; // Generate a weight between 1 and MAX_WEIGHT
            outFile << i << " " << j << " " << weight << std::endl;
            outFile << j << " " << i << " " << weight << std::endl; // Add reverse edge for undirected graph
        }
    }

    outFile.close();
    std::cout << "Graph with " << V << " vertices and " << V*(V-1) << " edges generated." << std::endl;

    return 0;
}

