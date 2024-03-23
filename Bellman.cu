#include <iostream>
#include <fstream>
#include <vector>
#include <limits.h>
#include <cuda_runtime.h>

#define INF INT_MAX

__global__ void bellmanFordKernel(int *d_edges, int *d_weights, int *d_distance, int numVertices, int numEdges) {
    int tid = threadIdx.x + blockIdx.x * blockDim.x;
    if (tid < numEdges) {
        int u = d_edges[tid * 2];
        int v = d_edges[tid * 2 + 1];
        int weight = d_weights[tid];
        if (d_distance[u] != INF && d_distance[u] + weight < d_distance[v]) {
            d_distance[v] = d_distance[u] + weight;
        }
    }
}

int main() {
    std::vector<int> h_edges; // Use a single vector to store both u and v of each edge
    std::vector<int> h_weights;
    int V = 0; // Number of vertices
    int E = 0; // Count edges while reading

    // Read graph from file
    std::ifstream graphFile("large_graph.txt");
    int u, v, w;
    while (graphFile >> u >> v >> w) {
        h_edges.push_back(u);
        h_edges.push_back(v);
        h_weights.push_back(w);
        int maxVertex = std::max(u, v);
        V = std::max(V, maxVertex + 1);
        E++;
    }
    graphFile.close();

    // Allocate memory on host
    int *h_distance = new int[V];
    for (int i = 0; i < V; ++i) {
        h_distance[i] = INF;
    }
    h_distance[0] = 0; // Assuming source vertex is 0

    // Allocate memory on device
    int *d_edges, *d_weights, *d_distance;
    cudaMalloc(&d_edges, sizeof(int) * 2 * E);
    cudaMalloc(&d_weights, sizeof(int) * E);
    cudaMalloc(&d_distance, sizeof(int) * V);

    // Copy data from host to device
    cudaMemcpy(d_edges, h_edges.data(), sizeof(int) * 2 * E, cudaMemcpyHostToDevice);
    cudaMemcpy(d_weights, h_weights.data(), sizeof(int) * E, cudaMemcpyHostToDevice);
    cudaMemcpy(d_distance, h_distance, sizeof(int) * V, cudaMemcpyHostToDevice);

    // Kernel launch parameters
    dim3 block(256);
    dim3 grid((E + block.x - 1) / block.x);

    // Execute the Bellman-Ford algorithm
    for (int i = 0; i < V - 1; ++i) {
        bellmanFordKernel<<<grid, block>>>(d_edges, d_weights, d_distance, V, E);
        cudaDeviceSynchronize();
    }

    // Copy results back to host
    cudaMemcpy(h_distance, d_distance, sizeof(int) * V, cudaMemcpyDeviceToHost);

    // Print the shortest distances
    std::cout << "Vertex Distance from Source" << std::endl;
    for (int i = 0; i < V; ++i) {
        std::cout << i << "\t\t" << (h_distance[i] == INF ? "INF" : std::to_string(h_distance[i])) << std::endl;
    }

    // Free device memory
    cudaFree(d_edges);
    cudaFree(d_weights);
    cudaFree(d_distance);

    // Free host memory
    delete[] h_distance;

    return 0;
}
