// Load the article dataset

// Step 1: Create some uniqueness constraints

CREATE CONSTRAINT uniqueColourGroup IF NOT EXISTS FOR (n:ColourGroup) REQUIRE (n.code) IS UNIQUE;
CREATE CONSTRAINT uniqueColourValue IF NOT EXISTS FOR (n:PerceivedColourValue) REQUIRE (n.id) IS UNIQUE;
CREATE CONSTRAINT uniqueColourMaster IF NOT EXISTS FOR (n:PerceivedColourMaster) REQUIRE (n.id) IS UNIQUE;
CREATE CONSTRAINT uniqueProductType IF NOT EXISTS FOR (n:ProductType) REQUIRE (n.number) IS UNIQUE;
CREATE CONSTRAINT uniqueProductGroup IF NOT EXISTS FOR (n:ProductGroup) REQUIRE (n.name) IS UNIQUE;
CREATE CONSTRAINT uniqueAppearance IF NOT EXISTS FOR (n:GraphicalAppearance) REQUIRE (n.number) IS UNIQUE;
CREATE CONSTRAINT uniqueDepartment IF NOT EXISTS FOR (n:Department) REQUIRE (n.number) IS UNIQUE;
CREATE CONSTRAINT uniqueSection IF NOT EXISTS FOR (n:Section) REQUIRE (n.number) IS UNIQUE;
CREATE CONSTRAINT uniqueIndex IF NOT EXISTS FOR (n:Index) REQUIRE (n.code) IS UNIQUE;
CREATE CONSTRAINT uniqueIndexGroup IF NOT EXISTS FOR (n:IndexGroup) REQUIRE (n.number) IS UNIQUE;
CREATE CONSTRAINT uniqueGarmentGroup IF NOT EXISTS FOR (n:GarmentGroup) REQUIRE (n.number) IS UNIQUE;
CREATE CONSTRAINT uniqueProduct IF NOT EXISTS FOR (n:Product) REQUIRE (n.code) IS UNIQUE;

// Load the csv file located in imports directory  

LOAD CSV WITH HEADERS FROM 'file:///articles.csv' AS row
MERGE (ga:GraphicalAppearance {number: row.graphical_appearance_no})
  ON CREATE SET
    ga.name = row.graphical_appearance_name
MERGE (dept:Department {number: row.department_no})
  ON CREATE SET
    dept.name = row.department_name
MERGE (sect:Section {number: row.section_no})
  ON CREATE SET
    sect.name = row.section_name
MERGE (indx:Index {code: row.index_code})
  ON CREATE SET
    indx.name = row.index_name
MERGE (indxGrp:IndexGroup {number: row.index_group_no})
  ON CREATE SET
    indxGrp.name = row.index_group_name
MERGE (garmGrp:GarmentGroup {number: row.garment_group_no})
  ON CREATE SET
    garmGrp.name = row.garment_group_name
MERGE (pcv: PerceivedColourValue {id: row.perceived_colour_value_id})
  ON CREATE SET
    pcv.name = row.perceived_colour_value_name
MERGE (pcm: PerceivedColourMaster {id: row.perceived_colour_master_id})
  ON CREATE SET
    pcm.name = row.perceived_colour_master_name
MERGE (cg: ColourGroup {code: row.colour_group_code})
  ON CREATE SET
    cg.name = row.colour_group_name
MERGE (prodType:ProductType {number: row.product_type_no})
  ON CREATE SET
    prodType.name = row.product_type_name
MERGE (prodGrp:ProductGroup {name: row.product_group_name})
MERGE (prod:Product {code: row.article_id})
  ON CREATE SET
    prod.name = row.prod_name,
    prod.description = prod.detail_desc
WITH ga, dept, sect, indx, indxGrp, garmGrp, pcv, pcm, cg, prodType, prodGrp, prod
MERGE (cg)-[:HAS_COLOUR_VALUE]->(pcv)
MERGE (cg)-[:HAS_MASTER_COLOUR]->(pcm)
MERGE (prod)-[:HAS_COLOUR]->(cg)
MERGE (prod)-[:SUBSET_OF]->(prodType)
MERGE (prodType)-[:SUBSET_OF]->(prodGrp)
MERGE (prod)-[:HAS_APPEARANCE_TYPE]->(ga)  
MERGE (prod)-[:FROM_DEPARTMENT]->(dept)
MERGE (dept)-[:FROM_SECTION]->(sect) 
MERGE (prod)-[:HAS_INDEX]->(indx)
MERGE (indx)-[:HAS_GROUP]->(indxGrp)
MERGE (prod)-[:HAS_GARMENT_GROUP]->(garmGrp);

