//Fabric Setup - https://neo4j.com/blog/getting-started-with-neo4j-fabric/

:use system;

create database products;

use products:

CREATE CONSTRAINT uniqueProduct IF NOT EXISTS FOR (n:Product) REQUIRE (n.code) IS UNIQUE;

LOAD CSV WITH HEADERS FROM 'file:///articles.csv' AS row
MERGE (prod:Product {code: row.article_id})



