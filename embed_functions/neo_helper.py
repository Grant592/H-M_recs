import logging
import sys
from neo4j import GraphDatabase
from neo4j.exceptions import ServiceUnavailable

class NeoProdEmbeddings:

    def __init__(self, uri, user, password):
        self.driver = GraphDatabase.driver(uri, auth=(user, password))

    def close(self):
        # Don't forget to close the driver connection when you are finished with it
        self.driver.close()

    @staticmethod
    def enable_log(level, output_stream):
        handler = logging.StreamHandler(output_stream)
        handler.setLevel(level)
        logging.getLogger("neo4j").addHandler(handler)
        logging.getLogger("neo4j").setLevel(level)

    def add_prod_embedding(self, prod_id, embedding):
        with self.driver.session(database='products') as session:
            # Write transactions allow the driver to handle retries and transient errors
            result = session.write_transaction(
                self._add_and_return_embedding, prod_id, embedding)
            for row in result:
                print(f"Created embedding for product ID {prod_id}")

    @staticmethod
    def _add_and_return_embedding(tx, prod_id, embedding):
        # To learn more about the Cypher syntax, see https://neo4j.com/docs/cypher-manual/current/
        # The Reference Card is also a good resource for keywords https://neo4j.com/docs/cypher-refcard/current/
        query = (
            "MERGE (prod:Product { code: $prod_id }) "
            "ON MATCH set prod.embedding = $embedding "
            "RETURN prod.code as prod_code, prod.embedding[0] as embedding_0"
        )
        result = tx.run(query, prod_id=prod_id,
                        embedding=embedding)
        try:
            return [
                {
                    "prod_code": row["prod_code"],
                    "embedding_0": row["embedding_0"]
                }
                    for row in result
            ]
        # Capture any errors along with the query and data for traceability
        except ServiceUnavailable as exception:
            logging.error(f"{query} raised an error: \n {exception}")
            raise