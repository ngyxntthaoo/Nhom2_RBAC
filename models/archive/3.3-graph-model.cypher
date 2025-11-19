MATCH (n) DETACH DELETE n;

CREATE 
  (alice:User {name: "Alice"}),
  (bob:User {name: "Bob"}),
  (manager:Role {name: "MANAGER"}),
  (employee:Role {name: "EMPLOYEE"}),
  (read:Permission {action: "READ"}),
  (doc1:Document {title: "Budget Report", sensitivity: 2}),
  (doc2:Document {title: "Meeting Notes", sensitivity: 1}),
  (doc3:Document {title: "Confidential Data", sensitivity: 3}),
  (alice)-[:HAS_ROLE]->(manager),
  (bob)-[:HAS_ROLE]->(employee),
  (manager)-[:CAN_ACCESS {level: 3}]->(read),
  (employee)-[:CAN_ACCESS {level: 1}]->(read);