// GDS Queries

// Compute some stats on the data first
// Average number of purchases per user
MATCH (c:Customer)-[:PURCHASED]->(p:Product)
WITH c, COUNT(p) AS num_purchases
WITH AVG(num_purchases) as avg_num_purchases, stDevP(num_purchases) as std_dev
RETURN avg_num_purchases, std_dev;

// Create a bipartite graph projection
CALL gds.graph.create(
    'user_items_graph',
    ['Customer', 'Product'],
    {
        PURCHASED: {
            type: 'PURCHASED',
            orientation: 'NATURAL'
        },
        PURCHASED_BY: {
            type: 'PURCHASED',
            orientation: 'REVERSE'
        }
    }
);

CALL gds.nodeSimilarity.mutate(
    'user_items_graph',
    {
        relationshipProjection: 'PURCHASED'
    }
)
YIELD *
RETURN *
