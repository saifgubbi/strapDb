 /****************************************************************************************************
  **  Name       : STRAP_TRIGGER_CREATION_SCRIPT.sql
  **  DESCRIPTION: This script is used to create the Triggers in STRAP Project
  **  MODIFICATION  HISTORY
  **  Change Number   Version  Date           Modified By      Remarks
  **  -               1.0      21-Aug-2017   Saif           Initial draft version
  ****************************************************************************************************/

CREATE OR REPLACE TRIGGER STRAP.AFTER_EVENTS_TRIG
AFTER INSERT ON STRAP.EVENTS_T
FOR EACH ROW
DECLARE
  lv_error_message VARCHAR2(1000);
  PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
   
	IF :NEW.EVENT_TYPE = 'Pallet' AND :NEW.EVENT_NAME='Palletised'
	THEN 
	    UPDATE PALLETS_T
           SET STATUS='Palletised',
               STATUS_DT=SYSDATE,
               FROM_LOC=:NEW.FROM_LOC,
               LABEL=:NEW.LABEL ,
               PART_NO=:NEW.PART_NO ,
               QTY=:NEW.QTY,
               PART_GRP=:NEW.PART_GRP
         WHERE PALLET_ID=:NEW.EVENT_ID
           AND STATUS='Ready';
    ELSIF :NEW.EVENT_TYPE = 'Bin' AND :NEW.EVENT_NAME='Palletised'
    THEN 
	    UPDATE BINS_T
           SET STATUS='Palletised',
               STATUS_DT=SYSDATE,
               PALLET_ID =:NEW.REF_ID,
               FROM_LOC=:NEW.FROM_LOC,
               LABEL=:NEW.LABEL ,
               PART_NO=:NEW.PART_NO ,
               QTY=:NEW.QTY,
               PART_GRP=:NEW.PART_GRP
         WHERE BIN_ID=:NEW.EVENT_ID
           AND STATUS='Ready';
    ELSIF :NEW.EVENT_TYPE='Invoice' AND :NEW.event_name='Add'
    THEN
        INSERT 
		  INTO INV_HDR_T
                (
                  INVOICE_NUM
                 ,INV_DT
                 ,FROM_LOC
                 ,TO_LOC
                 ,LR_NO
                 ,DEVICE_ID
                 ,STATUS
                 ,PART_GRP
                 ,USER_ID
                )
                VALUES
                ( :NEW.EVENT_ID--INV_NUM
                ,SYSDATE--INV_DT
                ,:NEW.FROM_LOC
                ,:NEW.TO_LOC
                ,NULL--LR_NO
                ,NULL--DEVICE_ID
                ,'New'--STATUS
                ,:NEW.PART_GRP--PART_GRP
                ,:NEW.USER_ID--USER_ID
                );
    
        INSERT 
		  INTO INV_LINE_T
               (
                INVOICE_NUM
               ,INV_DT
               ,LINE
               ,PART_NO
               ,QTY
               ,PART_GRP
               )
               VALUES
              (:NEW.EVENT_ID--INV_NUM
               ,SYSDATE
              ,:NEW.COMMENTS
              ,:NEW.PART_NO
              ,:NEW.QTY
              ,:NEW.PART_GRP
              );
    ELSIF :NEW.EVENT_TYPE='Invoice' AND :NEW.event_name='Delete'
    THEN
		DELETE 
		  FROM INV_HDR_T
		 WHERE INVOICE_NUM=:NEW.EVENT_ID;
    
        DELETE 
		  FROM INV_LINE_T
         WHERE INVOICE_NUM=:NEW.EVENT_ID;
    ELSIF :NEW.EVENT_TYPE = 'Pallet' AND :NEW.EVENT_NAME='Release'
    THEN 
	    UPDATE PALLETS_T
           SET STATUS='Ready',
               STATUS_DT=SYSDATE,
               FROM_LOC=:NEW.TO_LOC,
               LABEL=NULL ,
               PART_NO=NULL ,
               QTY=0,
               PART_GRP=NULL
         WHERE PALLET_ID=:NEW.EVENT_ID;  
    ELSIF :NEW.EVENT_TYPE = 'Bin' AND :NEW.EVENT_NAME='Release'
    THEN 
	    UPDATE BINS_T
           SET STATUS='Ready',
               STATUS_DT=SYSDATE,
               PALLET_ID =NULL,
               FROM_LOC=:NEW.TO_LOC,
               LABEL=NULL ,
               PART_NO=NULL ,
               QTY=0,
               PART_GRP=NULL
         WHERE BIN_ID=:NEW.EVENT_ID;
    ELSIF :NEW.EVENT_TYPE = 'Pallet' AND :NEW.EVENT_NAME='Invoiced'
    THEN
        UPDATE INV_HDR_T
           SET STATUS='Parts Assigned'
         WHERE INVOICE_NUM=:NEW.INVOICE_NUM;
    
        UPDATE PALLETS_T
           SET STATUS='Invoiced',  
               STATUS_DT=SYSDATE,
               INVOICE_NUM=:NEW.INVOICE_NUM,
               PART_GRP=:NEW.PART_GRP
         WHERE PALLET_ID=:NEW.EVENT_ID
           AND STATUS='Palletised';  
       
        UPDATE BINS_T
           SET STATUS='Invoiced',
               STATUS_DT=SYSDATE,
               INVOICE_NUM=:NEW.INVOICE_NUM,
               PART_GRP=:NEW.PART_GRP
         WHERE PALLET_ID=:NEW.EVENT_ID
           AND STATUS='Palletised';
       
    ELSIF :NEW.EVENT_TYPE = 'Pallet' AND :NEW.EVENT_NAME='Invoice Rev'
    THEN
        UPDATE PALLETS_T
           SET STATUS='Palletised',  
               STATUS_DT=SYSDATE,
               INVOICE_NUM=NULL,
               PART_GRP=:NEW.PART_GRP
         WHERE PALLET_ID=:NEW.EVENT_ID
           AND STATUS='Invoiced';  
       
         UPDATE BINS_T
            SET STATUS='Palletised',
                STATUS_DT=SYSDATE,
                INVOICE_NUM=NULL,
                PART_GRP=:NEW.PART_GRP
          WHERE PALLET_ID=:NEW.EVENT_ID
            AND STATUS='Invoiced';     
    ELSIF :NEW.EVENT_TYPE = 'Invoice' AND :NEW.EVENT_NAME='Invoice Rev'
    THEN
        UPDATE INV_HDR_T
           SET STATUS='New'
         WHERE INVOICE_NUM=:NEW.EVENT_ID
           AND STATUS='Parts Assigned';
    ELSIF :NEW.EVENT_TYPE = 'Bin' AND :NEW.EVENT_NAME='Invoiced'
    THEN
        UPDATE INV_HDR_T
           SET STATUS='Parts Assigned'
         WHERE INVOICE_NUM=:NEW.INVOICE_NUM;
       
        UPDATE BINS_T
           SET STATUS='Invoiced',
               STATUS_DT=SYSDATE,
               LABEL=NVL(:NEW.LABEL,LABEL),
               INVOICE_NUM=:NEW.INVOICE_NUM,
               PART_GRP=:NEW.PART_GRP
         WHERE BIN_ID=:NEW.EVENT_ID;
       
    ELSIF :NEW.EVENT_TYPE = 'Bin' AND :NEW.EVENT_NAME='Invoice Rev'
    THEN
     UPDATE BINS_T
      SET STATUS='Palletised',
          STATUS_DT=SYSDATE,
          INVOICE_NUM=NULL,
          PART_GRP=:NEW.PART_GRP
      WHERE PALLET_ID=:NEW.EVENT_ID
       AND STATUS='Invoiced'; 
       
  ELSIF :NEW.EVENT_TYPE = 'Invoice' AND :NEW.EVENT_NAME='LR Assigned'
  THEN
   UPDATE INV_HDR_T
      SET STATUS='LR Assigned',
          LR_NO =:NEW.LR_NO,
          DEVICE_ID =:NEW.DEVICE_NO
    WHERE INVOICE_NUM=:NEW.EVENT_ID; 
  ELSIF :NEW.EVENT_TYPE = 'Invoice' AND :NEW.EVENT_NAME='LR Assigned Rev'
  THEN
   UPDATE INV_HDR_T
      SET STATUS='Parts Assigned',
          LR_NO =NULL,
          DEVICE_ID =NULL
    WHERE INVOICE_NUM=:NEW.EVENT_ID
      AND STATUS='LR Assigned'; 
  ELSIF :NEW.EVENT_TYPE = 'Pallet' AND :NEW.EVENT_NAME='Dispatched'
  THEN 
     UPDATE PALLETS_T
      SET STATUS='Dispatched',  
          STATUS_DT=SYSDATE,
          INVOICE_NUM=:NEW.INVOICE_NUM,
          PART_GRP=:NEW.PART_GRP
      WHERE PALLET_ID=:NEW.EVENT_ID;  
       
     UPDATE BINS_T
      SET STATUS='Dispatched',
          STATUS_DT=SYSDATE,
          INVOICE_NUM=:NEW.INVOICE_NUM,
          PART_GRP=:NEW.PART_GRP
      WHERE PALLET_ID=:NEW.EVENT_ID; 
  ELSIF :NEW.EVENT_TYPE = 'Bin' AND :NEW.EVENT_NAME='Dispatched'
  THEN        
     UPDATE BINS_T
      SET STATUS='Dispatched',
          STATUS_DT=SYSDATE,
          INVOICE_NUM=:NEW.INVOICE_NUM,
          PART_GRP=:NEW.PART_GRP
      WHERE BIN_ID=:NEW.EVENT_ID; 
  ELSIF :NEW.EVENT_TYPE = 'Invoice' AND :NEW.EVENT_NAME='Dispatched'
  THEN
   UPDATE INV_HDR_T
      SET STATUS='Dispatched'
    WHERE INVOICE_NUM=:NEW.EVENT_ID; 
	/* For Manual Reached without geoFence*/
  ELSIF :NEW.EVENT_TYPE = 'Invoice' AND :NEW.EVENT_NAME='Reached'
  THEN 
	 UPDATE INV_HDR_T
         SET STATUS='Reached'
             --LR_NO =NULL,
             --DEVICE_ID =NULL
       WHERE INVOICE_NUM=:NEW.EVENT_ID; 
    
      UPDATE PALLETS_T
         SET STATUS='Reached',  
             STATUS_DT=SYSDATE,
             FROM_LOC=:NEW.FROM_LOC,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             PART_GRP=:NEW.PART_GRP
       WHERE INVOICE_NUM=:NEW.EVENT_ID;  
       
      UPDATE BINS_T
         SET STATUS='Reached',
             STATUS_DT=SYSDATE,
             FROM_LOC=:NEW.FROM_LOC,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             PART_GRP=:NEW.PART_GRP
       WHERE INVOICE_NUM=:NEW.EVENT_ID;
  ELSIF :NEW.EVENT_TYPE = 'Invoice' AND :NEW.EVENT_NAME='Geofence'
  THEN 
    IF :NEW.FROM_LOC <>:NEW.TO_LOC
      THEN
        NULL;
    ELSE
      UPDATE INV_HDR_T
         SET STATUS='Reached'
            -- LR_NO =NULL,
            -- DEVICE_ID =NULL
       WHERE INVOICE_NUM=:NEW.EVENT_ID; 
    
      UPDATE PALLETS_T
         SET STATUS='Reached',  
             STATUS_DT=SYSDATE,
             FROM_LOC=:NEW.FROM_LOC,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             PART_GRP=:NEW.PART_GRP
       WHERE INVOICE_NUM=:NEW.EVENT_ID;  
       
      UPDATE BINS_T
         SET STATUS='Reached',
             STATUS_DT=SYSDATE,
             FROM_LOC=:NEW.FROM_LOC,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             PART_GRP=:NEW.PART_GRP
       WHERE INVOICE_NUM=:NEW.EVENT_ID;
      END IF;
  ELSIF :NEW.EVENT_TYPE IN ('Pallet','Bin','Invoice') AND :NEW.EVENT_NAME='Received'
  THEN
    IF :NEW.EVENT_TYPE='Pallet'
    THEN
     UPDATE PALLETS_T
         SET STATUS='In Stock',  
             STATUS_DT=SYSDATE,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             FROM_LOC=:NEW.FROM_LOC,
             PART_GRP=:NEW.PART_GRP
       WHERE PALLET_ID=:NEW.EVENT_ID;  
       
      UPDATE BINS_T
         SET STATUS='In Stock',
             STATUS_DT=SYSDATE,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             FROM_LOC=:NEW.FROM_LOC,
             PART_GRP=:NEW.PART_GRP
       WHERE PALLET_ID=:NEW.EVENT_ID;
     ELSIF :NEW.EVENT_TYPE='Bin'
     THEN
      UPDATE BINS_T
         SET STATUS='In Stock',
             STATUS_DT=SYSDATE,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             FROM_LOC=:NEW.FROM_LOC,
             PART_GRP=:NEW.PART_GRP
       WHERE BIN_ID=:NEW.EVENT_ID;
      ELSIF :NEW.EVENT_TYPE='Invoice'
      THEN
       UPDATE INV_HDR_T
         SET STATUS='Received',
             LR_NO =NULL,
             DEVICE_ID =NULL
       WHERE INVOICE_NUM=:NEW.EVENT_ID; 
      ELSE
        NULL;
      END IF;
  ELSIF :NEW.EVENT_TYPE IN ('Pallet','Bin') AND :NEW.EVENT_NAME='Review'
  THEN
    IF :NEW.EVENT_TYPE='Pallet'
    THEN
     UPDATE PALLETS_T
         SET STATUS='Review',  
             STATUS_DT=SYSDATE,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             FROM_LOC=:NEW.FROM_LOC,
             PART_GRP=:NEW.PART_GRP
       WHERE PALLET_ID=:NEW.EVENT_ID;  
       
      UPDATE BINS_T
         SET STATUS='Review',
             STATUS_DT=SYSDATE,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             FROM_LOC=:NEW.FROM_LOC,
             PART_GRP=:NEW.PART_GRP
       WHERE PALLET_ID=:NEW.EVENT_ID;
     ELSIF :NEW.EVENT_TYPE='Bin'
     THEN
      UPDATE BINS_T
         SET STATUS='Review',
             STATUS_DT=SYSDATE,
             INVOICE_NUM=:NEW.INVOICE_NUM,
             FROM_LOC=:NEW.FROM_LOC,
             PART_GRP=:NEW.PART_GRP
       WHERE BIN_ID=:NEW.EVENT_ID;
      ELSE
        NULL;
      END IF;
  ELSIF :NEW.EVENT_TYPE ='Bin' AND :NEW.EVENT_NAME='Picked' AND :NEW.EVENT_ID <> :NEW.REF_ID
  THEN
      UPDATE BINS_T
         SET STATUS='Picked',
             STATUS_DT=SYSDATE,
             INVOICE_NUM=NULL,
             FROM_LOC=:NEW.FROM_LOC,
             PART_GRP=:NEW.PART_GRP,
             QTY=QTY+:NEW.QTY
       WHERE BIN_ID=:NEW.EVENT_ID;
  ELSIF :NEW.EVENT_TYPE ='Bin' AND :NEW.EVENT_NAME='Transferred' AND :NEW.EVENT_ID <> :NEW.REF_ID
  THEN    
        UPDATE BINS_T
         SET QTY=QTY-:NEW.QTY
       WHERE BIN_ID=:NEW.EVENT_ID;
  ELSIF :NEW.EVENT_TYPE ='Bin' AND :NEW.EVENT_NAME='Picked'
  THEN
      UPDATE BINS_T
         SET STATUS='Picked',
             STATUS_DT=SYSDATE,
             INVOICE_NUM=NULL,
             FROM_LOC=:NEW.FROM_LOC,
             PART_GRP=:NEW.PART_GRP,
             QTY=:NEW.QTY
       WHERE BIN_ID=:NEW.EVENT_ID;
  ELSIF :NEW.EVENT_TYPE IN ('Invoice') AND :NEW.EVENT_NAME='ASN Assigned'
  THEN
  INSERT INTO ASN_T
  (
    ASN_ID
   ,ASN_LINE	
   ,ASN_DATE	
   ,INVOICE_NUM	
   ,CUST_PART_NO	
   ,PART_NO	
   ,QTY	
   ,PART_GRP	
   ,USER_ID	
   )
   VALUES
   ( 	
    :NEW.ref_label--ASN_ID
   ,:NEW.comments
   , SYSDATE	
   ,:NEW.EVENT_ID	
   ,:NEW.PART_NO	
   ,:NEW.PART_NO	
   ,:NEW.QTY	
   ,:NEW.PART_GRP	
   ,:NEW.USER_ID	
   );
   
   UPDATE INV_HDR_T
      SET STATUS='ASN Assigned',
          LR_NO =NULL,
          DEVICE_ID =NULL
    WHERE INVOICE_NUM=:NEW.EVENT_ID;
  ELSIF :NEW.EVENT_TYPE IN ('Invoice') AND :NEW.EVENT_NAME='ASN Delete'
  THEN
     DELETE FROM ASN_T
      WHERE INVOICE_NUM =:NEW.EVENT_ID;
   
   UPDATE INV_HDR_T
      SET STATUS='New'
    WHERE INVOICE_NUM=:NEW.EVENT_ID; 
	END IF;
  COMMIT;
EXCEPTION
WHEN OTHERS THEN
raise_application_error (-20001,'Error ! When Updating :'||SQLERRM);   
END;
/
Show Err;
/


 -- Create Before Schedule Trigger
CREATE OR REPLACE TRIGGER STRAP.BEFORE_SCHED_TRIG
BEFORE INSERT
ON SCHED_T
FOR EACH ROW
DECLARE v_partNo VARCHAR2(20);

BEGIN
   -- Get the Part Number
   BEGIN
    SELECT PART_NO 
      INTO v_partNo 
	 FROM PARTS_T 
	WHERE CUST_PART_NO = :new.CUST_PART_NO;
   EXCEPTION
   WHEN OTHERS THEN
     v_partNo :=NULL;
   END;
   
   :new.PART_NO := v_partNo;
   
EXCEPTION
WHEN NO_DATA_FOUND THEN
raise_application_error (-20001,'No data available for this customer part number');   
END;
/
Show Err;
/

-- Create Before Serial Trigger
CREATE OR REPLACE TRIGGER STRAP.BEFORE_SERIAL_TRIG
BEFORE INSERT ON SERIAL_T
FOR EACH ROW
DECLARE 
v_partNo VARCHAR2(20);
v_binid  VARCHAR2(16);
BEGIN
   -- Get the Part Number
   BEGIN
    SELECT PART_NO 
      INTO v_partNo 
	  FROM PARTS_T 
	 WHERE PART_NO = SUBSTR(:new.PART_NO,1,4)||'.'||SUBSTR(:new.PART_NO,5,3)||'.'||SUBSTR(:new.PART_NO,8,3)||'-'||SUBSTR(:new.PART_NO,11,3);
	-- WHERE REGEXP_REPLACE(PART_NO ,'[^[:alnum:]'' '']', NULL) = :new.PART_NO;
   EXCEPTION 
   WHEN OTHERS THEN
     v_partNo :=NULL;
   END;
   
   :new.PART_NO := v_partNo;
   
   BEGIN
    SELECT BIN_ID 
      INTO v_binid 
	  FROM BINS_T 
	 WHERE LABEL = :new.BIN_LABEL;
   EXCEPTION
   WHEN OTHERS THEN
     v_binid :=NULL;
   END;
   
   :new.BIN_ID := v_binid;
   
EXCEPTION
WHEN NO_DATA_FOUND THEN
raise_application_error (-20001,'No data available for this Serial Number :');   
END;
/
Show Err;
/
