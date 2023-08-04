CREATE DATABASE BANKING;
USE BANKING;

CREATE TABLE accounts(id int, amount decimal);

INSERT INTO accounts(id, amount) VALUES (1, 1000);
INSERT INTO accounts(id, amount) VALUES (2, 500);
INSERT INTO accounts(id, amount) VALUES (3, 250);

SELECT * FROM accounts;
