-- 
-- Created by SQL::Translator::Producer::Oracle
-- Created on Mon Dec 23 13:25:40 2019
-- 
;
--
-- Table: dbix_class_deploymenthandler_versions
--;
CREATE SEQUENCE "sq_dbix_class_deploymenthandle";
CREATE TABLE "dbix_class_deploymenthandler_versions" (
  "id" number NOT NULL,
  "version" varchar2(50) NOT NULL,
  "ddl" clob,
  "upgrade_sql" clob,
  PRIMARY KEY ("id"),
  CONSTRAINT "dbix_class_deploymenthandler_versions_version" UNIQUE ("version")
);
CREATE OR REPLACE TRIGGER "ai_dbix_class_deploymenthandle"
BEFORE INSERT ON "dbix_class_deploymenthandler_versions"
FOR EACH ROW WHEN (
 new."id" IS NULL OR new."id" = 0
)
BEGIN
 SELECT "sq_dbix_class_deploymenthandle".nextval
 INTO :new."id"
 FROM dual;
END;
;
