/********************************************************************************************************************************************************************
  **  Name       : STRAP_TABLE_CREATION_SCRIPT
  **  DESCRIPTION: This script is used to create all the tables in Bosch Strap
  **  MODIFICATION  HISTORY
  **  Change Number   Version  Date           Modified By      Remarks
  **  -               1.0      17-Aug-2017    Saif             Initial draft version
  ************************************************************************************************************************************************************/

--Drop All Tables 

DROP TABLE EVENTS_T;
DROP TABLE BINS_T;
DROP TABLE PALLETS_T;
DROP TABLE USERS_T;
DROP TABLE PARTS_T;
DROP TABLE ASN_T;
DROP TABLE LOCATIONS_T;
DROP TABLE SCHED_T;
-- DROP TABLE INV_PALLET_T;
DROP TABLE UPLOAD_LOG_T;
DROP TABLE USER_PARTS_T;
DROP TABLE PARTS_GRP_T;
DROP TABLE INV_HDR_T;
DROP TABLE INV_LINE_T;
DROP TABLE SERIAL_T;
--Creation of EVENTS_T Table

  CREATE TABLE STRAP.EVENTS_T
   (  EVENT_ID                  VARCHAR2(20), 
	  EVENT_TYPE                VARCHAR2(20), 
	  EVENT_NAME                VARCHAR2(20), 
	  EVENT_DATE                DATE, 
	  FROM_LOC                  VARCHAR2(5), 
      TO_LOC                    VARCHAR2(5),
	  LABEL                     VARCHAR2(20), 
	  PART_NO                   VARCHAR2(16), 
	  QTY                       NUMBER, 
	  INVOICE_NUM               VARCHAR2(20), 
	  USER_ID                   VARCHAR2(20) NOT NULL, 
	  COMMENTS                  VARCHAR2(2000), 
	  SEQ                       NUMBER, 
	  EVENT_TS                  NUMBER, 
	  REF_ID                    VARCHAR2(20),
	  REF_LABEL                 VARCHAR2(20),
      PART_GRP                  VARCHAR2(4),
      LR_NO                     VARCHAR2(20),
      DEVICE_NO                 VARCHAR2(20),
	  SERIAL_NUM	            NUMBER,
    CONSTRAINT PK_EVENTS primary key(EVENT_ID, EVENT_TYPE,EVENT_NAME,SEQ,EVENT_TS)
   ) ;

-- CREATE OR REPLACE SYNONYM APPS.EVENTS_T FOR STRAP.EVENTS_T;

-- Create Table BINS_T

--alter table bins_t modify bin_id NUMBER  VARCHAr2(16);
CREATE TABLE STRAP.BINS_T 
   (  BIN_ID                    VARCHAR2(16) NOT NULL , 
	  STATUS                    VARCHAR2(20) NOT NULL , 
	  STATUS_DT                 DATE, 
	  FROM_LOC                  VARCHAR2(5) NOT NULL , 
	  PALLET_ID                 NUMBER, 
      LABEL                     VARCHAR2(20), 
	  INVOICE_NUM               VARCHAR2(20),
	  STATE                     NUMBER DEFAULT 1 NOT NULL, -- To Indicate Active/Inactive
	  PART_NO                   VARCHAR2(20), 
	  QTY                       NUMBER DEFAULT 0 NOT NULL, 
	  OWNER                     VARCHAR2(20) NOT NULL , 
	  SEQ                       NUMBER DEFAULT 0 NOT NULL ,
      PART_GRP                  VARCHAR2(4),
	 CONSTRAINT PK_BINS PRIMARY KEY (BIN_ID)
    );

-- CREATE OR REPLACE SYNONYM APPS.BINS_T FOR STRAP.BINS_T;

-- Creation of DROP TABLE PALLETS_T 
  CREATE TABLE STRAP.PALLETS_T 
   (PALLET_ID                 VARCHAR2(16) NOT NULL, 
	  STATUS                    VARCHAR2(20), 
	  STATUS_DT                 DATE, 
	  FROM_LOC                  VARCHAR2(5), 
	  LABEL                     VARCHAR2(20), 
	  INVOICE_NUM               VARCHAR2(20), 
	  STATE                     VARCHAR2(20), 
	  PART_NO                   VARCHAR2(20), 
	  QTY                       NUMBER, 
	  OWNER                     VARCHAR2(20), 
	  SEQ                       NUMBER, 
    PART_GRP                  VARCHAR2(4),
	  CONSTRAINT PK_PALLETS PRIMARY KEY (PALLET_ID)
   );
   
--CREATE OR REPLACE SYNONYM APPS.PALLETS_T FOR STRAP.PALLETS_T;   


   -- Creation of table USERS_T
   
   CREATE TABLE STRAP.USERS_T
   (  USER_ID                   VARCHAR2(8) NOT NULL, 
	  PASSWORD                  VARCHAR2(60), 
	  NAME                      VARCHAR2(70), 
	  EMAIL                     VARCHAR2(70), 
	  PHONE                     NUMBER(10,0), 
	  ROLE                      VARCHAR2(20), 
	  LOC_ID                    VARCHAR2(5), 
	  PART_GRP                  VARCHAR2(4), 
	  CONSTRAINT PK_USERS PRIMARY KEY (USER_ID)
   ) ;  
 
-- CREATE OR REPLACE SYNONYM APPS.USERS_T FOR STRAP.USERS_T;     
 
 
 -- Creation of PARTS_T
 
   CREATE TABLE STRAP.PARTS_T
   (  PART_GRP                  VARCHAR2(4) NOT NULL, 
      PART_NO                   VARCHAR2(20) NOT NULL, 
	  CUST_PART_NO              VARCHAR2(20), 
	  VARIANT                   VARCHAR2(20), 
	  PARTS_TYPE                VARCHAR2(20), 
	  SERIALIZED	            VARCHAR2(1) DEFAULT 'N',
	 CONSTRAINT PK_MATERIAL PRIMARY KEY (PART_GRP, PART_NO)
   );
   
  -- CREATE OR REPLACE SYNONYM APPS.PARTS_T FOR STRAP.PARTS_T;   
   
   -- Creation of ASN_T
  CREATE TABLE STRAP.ASN_T 
   (  ASN_ID                    VARCHAR2(20) NOT NULL , 
	  ASN_LINE                  NUMBER NOT NULL, 
	  ASN_DATE                  DATE NOT NULL , 
      INVOICE_NUM               VARCHAR2(20), 
	  CUST_PART_NO              VARCHAR2(20), 
 	  PART_NO                   VARCHAR2(20), 
	  QTY                       NUMBER, 
	  PART_GRP                  VARCHAR2(4), 
	  USER_ID                   VARCHAR2(20),
	 CONSTRAINT PK_ASN_TBL PRIMARY KEY (ASN_ID,ASN_LINE,ASN_DATE)
  );
  
   --CREATE OR REPLACE SYNONYM APPS.ASN_T FOR STRAP.ASN_T; 
   
  CREATE TABLE STRAP.LOCATIONS_T 
   (  LOC_ID                     VARCHAR2(5) NOT NULL, 
	  DESCRIPTION                VARCHAR2(20), 
	  TYPE                       VARCHAR2(20), 
      CLOSE_STATUS               VARCHAR2(20),
      LAT                        NUMBER,
      LON                        NUMBER,
    CONSTRAINT PK_LOCATIONS PRIMARY KEY (LOC_ID)
   );
     --CREATE OR REPLACE SYNONYM APPS.LOCATIONS_T FOR STRAP.LOCATIONS_T; 
     
     
   CREATE TABLE STRAP.SCHED_T
   (  SCHED_DT                  DATE NOT NULL, 
	  SCHED_HR                  NUMBER DEFAULT 0 NOT NULL, 
	  CUST_PART_NO              VARCHAR2(20) NOT NULL, 
	  PART_NO                   VARCHAR2(20), 
	  WIP_QTY                   NUMBER, 
	  QTY                       NUMBER, 
	  PART_GRP                  VARCHAR2(4), 
	  USER_ID                   VARCHAR2(20), 
	 CONSTRAINT PK_SCHED_TBL PRIMARY KEY (SCHED_DT,CUST_PART_NO, SCHED_HR)
   );
     --CREATE OR REPLACE SYNONYM APPS.SCHED_T FOR STRAP.SCHED_T; 
     
  /*   
     CREATE TABLE STRAP.INV_PALLET_T
   (  INVOICE_NUM             VARCHAR2(20) NOT NULL , 
	  INV_DT                    VARCHAR2(20) NOT NULL , 
	  LABEL                     VARCHAR2(20) NOT NULL , 
	  OBJ_ID                    VARCHAR2(20), 
	  PART_NO                   VARCHAR2(20), 
	  QTY                       VARCHAR2(20), 
	  LOC_ID                    VARCHAR2(5), 
	  USER_ID                   VARCHAR2(20), 
	  TYPE                      VARCHAR2(20), 
	 CONSTRAINT PK_INV_PALLET PRIMARY KEY (INVOICE_NUM,INV_DT,LABEL)
  );
    --CREATE OR REPLACE SYNONYM APPS.INV_PALLET_T FOR STRAP.INV_PALLET_T;
   --
   */
   -- DROP TABLE STRAP.UPLOAD_LOG_T 
    CREATE TABLE STRAP.UPLOAD_LOG_T 
   (  SEQ                       NUMBER NOT NULL, 
	  TYPE                      VARCHAR2(20), 
	  USER_ID                   VARCHAR2(20), 
	  TOTAL                     NUMBER, 
	  SUCCESS                   NUMBER, 
	  ERROR                     NUMBER, 
	  SYSFILENAME               VARCHAR2(100), 
	  ORIGFILENAME              VARCHAR2(100), 
	  LOGFILENAME               VARCHAR2(100), 
	  DESCRIPTION               VARCHAR2(100), 
	  PART_GRP                  VARCHAR2(4) NOT NULL,
	  CONSTRAINT PK_UPLOAD_LOG PRIMARY KEY (SEQ)
   );
     --CREATE OR REPLACE SYNONYM APPS.UPLOAD_LOG_T FOR STRAP.UPLOAD_LOG_T; 
    -- DROP TABLE STRAP.USER_PARTS_T
   CREATE TABLE STRAP.USER_PARTS_T
   ( USER_ID                   VARCHAR2(20) NOT NULL, 
	 PART_GRP                  VARCHAR2(4) NOT NULL,
	 CONSTRAINT PK_USER_PARTS PRIMARY KEY (USER_ID,PART_GRP)
   );
    --CREATE OR REPLACE SYNONYM APPS.USER_PARTS_T FOR STRAP.USER_PARTS_T; 
    -- DROP TABLE STRAP.PARTS_GRP_T
  CREATE TABLE STRAP.PARTS_GRP_T
   (PART_GRP                   VARCHAR2(4) NOT NULL, 
	DESCRIPTION                VARCHAR2(50), 
    OWNER                      VARCHAR2(20) NOT NULL,
	  CONSTRAINT PK_PART_GRP PRIMARY KEY (PART_GRP)
   );
    --CREATE OR REPLACE SYNONYM APPS.PARTS_GRP_T FOR STRAP.PARTS_GRP_T; 
   -- Creation of XX_STRAP_INV_HDR_T

  CREATE TABLE STRAP.INV_HDR_T 
   (  INVOICE_NUM               VARCHAR2(20) NOT NULL, 
	  INV_DT                    DATE NOT NULL , 
	  FROM_LOC                  VARCHAR2(5), 
	  TO_LOC                    VARCHAR2(5), 
	  LR_NO                     VARCHAR2(20), 
	  DEVICE_ID                 VARCHAR2(20), 
	  STATUS                    VARCHAR2(20), 
      PART_GRP                  VARCHAR2(4),
      USER_ID                   VARCHAR2(20) NOT NULL, 
	 CONSTRAINT PK_INV_HDR PRIMARY KEY (INVOICE_NUM, INV_DT)
   );
    
--CREATE OR REPLACE SYNONYM APPS.INV_HDR_T FOR STRAP.INV_HDR_T;   

  CREATE TABLE STRAP.INV_LINE_T 
   (  INVOICE_NUM               VARCHAR2(20) NOT NULL, 
	  INV_DT                    DATE NOT NULL, 
	  LINE                      NUMBER NOT NULL, 
	  PART_NO                   VARCHAR2(20), 
	  QTY                       NUMBER,
      PART_GRP                  VARCHAR2(4),
	 CONSTRAINT PK_INV_LINE PRIMARY KEY (INVOICE_NUM,INV_DT,LINE)
   );
  
--CREATE OR REPLACE SYNONYM APPS.INV_LINE_T FOR STRAP.INV_LINE_T;    

-- 
  CREATE TABLE STRAP.SERIAL_T 
   ( SERIAL_DT	                DATE
     ,SERIAL_NUM	            NUMBER
     ,BIN_LABEL	                VARCHAR2(20)
     ,BIN_ID	                VARCHAR2(16)
     ,PART_NO	                VARCHAR2(20)	 
	 ,PART_GRP                  VARCHAR2(4) 
	 ,USER_ID                   VARCHAR2(20)
	 ,CONSTRAINT PK_SER_N PRIMARY KEY (SERIAL_NUM,BIN_LABEL)
   );
  
--CREATE OR REPLACE SYNONYM APPS.SERIAL_T FOR STRAP.SERIAL_T;  

  CREATE TABLE STRAP.DEVICE_T 
   (  DEVICE_NO                 VARCHAR2(20) NOT NULL, 
	  PART_GRP                  VARCHAR2(4) ,
    CONSTRAINT PK_DEVICE PRIMARY KEY (DEVICE_NO)
   );
     --CREATE OR REPLACE SYNONYM APPS.DEVICE_T FOR STRAP.DEVICE_T; 
	 
   CREATE TABLE STRAP.GEOFENCE_T 
   (  GEOFENCE_ID                VARCHAR2(50) NOT NULL,   
      TYPE                       VARCHAR2(10),
      MAP_VAL                    VARCHAR2(50), 
	  DESCRIPTION                VARCHAR2(50)
   );
     --CREATE OR REPLACE SYNONYM APPS.GEOFENCE_T FOR STRAP.GEOFENCE_T; 