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
    prod.description = row.detail_desc
WITH ga, dept, sect, indx, indxGrp, garmGrp, pcv, pcm, cg, prodType, prodGrp, prod
MERGE (prod)-[:HAS_COLOUR_VALUE]->(pcv)
MERGE (prod)-[:HAS_MASTER_COLOUR]->(pcm)
MERGE (prod)-[:HAS_COLOUR]->(cg)
MERGE (prod)-[:SUBSET_OF]->(prodType)
MERGE (prodType)-[:SUBSET_OF]->(prodGrp)
MERGE (prod)-[:HAS_APPEARANCE_TYPE]->(ga)  
MERGE (prod)-[:FROM_DEPARTMENT]->(dept)
MERGE (dept)-[:FROM_SECTION]->(sect) 
MERGE (prod)-[:HAS_INDEX]->(indx)
MERGE (indx)-[:HAS_GROUP]->(indxGrp)
MERGE (prod)-[:HAS_GARMENT_GROUP]->(garmGrp);


// Loading the customer data 
CREATE CONSTRAINT uniqueCustomer IF NOT EXISTS FOR (n:Customer) REQUIRE (n.id) IS UNIQUE;
// CREATE CONSTRAINT uniquePostcode IF NOT EXISTS FOR (n:PostalCode) REQUIRE (n.postal_code) IS UNIQUE;

LOAD CSV WITH HEADERS FROM 'file:///customers.csv' AS row
CALL {
  WITH row
  MERGE (c:Customer {id: row.customer_id})
  ON CREATE SET 
    c.club_member_status =
      CASE
        WHEN  row.club_member_status IS NULL THEN 'NOT_ACTIVE'
        ELSE  row.club_member_status
      END,
    c.active =
      CASE
        WHEN row.Active IS NULL THEN 0
        ELSE row.Active
      END,
    c.fn = 
      CASE
        WHEN row.FN IS NULL THEN 0
        ELSE row.FN
      END,
    c.fashion_news_frequency = 
      CASE
        WHEN row.fashion_news_frequency IS NULL THEN 'NONE'
        ELSE row.fashion_news_frequency
      END,
    c.age = 
      CASE
         WHEN row.age IS NULL THEN 100
         ELSE row.age
      END,
    c.postal_code = 
      CASE
         WHEN row.postal_code IS NULL THEN 'NONE'
         ELSE row.postal_code
      END

} IN TRANSACTIONS OF 1000 ROWS;

    
// Load transaction data
LOAD CSV WITH HEADERS FROM 'file:///transactions_train.csv' AS row
CALL {
  WITH row
  MATCH (c:Customer {id: row.customer_id})
  MATCH (p:Product {code: row.article_id})
  MERGE (c)-[:PURCHASED {t_date: date(row.t_dat), price: row.price, sales_channel: row.sales_channel_id}]->(p)
} IN TRANSACTIONS OF 1000 ROWS;


// Add AgeGroup Nodes
WITH [[16,25],[26,35],[36,45],[46,55],[56,65],[65,99],[100,100]] as ageGroups
UNWIND ageGroups as ag
CREATE (:AgeGroup {lower: ag[0], upper: ag[1]});

// Create relationship between age group and customer
MATCH (c:Customer)
MATCH (a:AgeGroup) WHERE toInteger(c.age) >= a.lower AND toInteger(c.age) <= a.upper
CREATE (c)-[:IS_AGE_GROUP]->(a);
