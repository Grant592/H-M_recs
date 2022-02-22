// GDS Queries
// Use appropriate database
:use products;

// Create graph projection with node properties
CALL gds.graph.create(
    'knnGraph',
    {
        Product: {
            label: 'Product',
            properties:'embedding'
        }
    },
    '*'
);

// Create the top 10 nearest neighbours based on the image embeddings
CALL gds.beta.knn.write('knnGraph', {
    writeRelationshipType: 'SIMILAR',
    writeProperty: 'score',
    topK: 10,
    randomSeed: 42,
    concurrency: 1,
    nodeWeightProperty: 'embedding'
})
YIELD nodesCompared, relationshipsWritten;