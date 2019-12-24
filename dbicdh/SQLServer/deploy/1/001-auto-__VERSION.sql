-- 
-- Created by SQL::Translator::Generator::Role::DDL
-- Created on Mon Dec 23 13:25:40 2019
-- 


--
-- Table: [dbix_class_deploymenthandler_versions]
--
CREATE TABLE [dbix_class_deploymenthandler_versions] (
  [id] int IDENTITY NOT NULL,
  [version] varchar(50) NOT NULL,
  [ddl] longtext NULL,
  [upgrade_sql] longtext NULL,
  CONSTRAINT [dbix_class_deploymenthandler_versions_pk] PRIMARY KEY ([id]),
  CONSTRAINT [dbix_class_deploymenthandler_versions_version] UNIQUE ([version])
);
;
