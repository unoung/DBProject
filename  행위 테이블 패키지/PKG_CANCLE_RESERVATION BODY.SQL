create or replace NONEDITIONABLE PACKAGE BODY PKG_CANCLE_RESERVATION AS

  PROCEDURE PROC_INS_CANCLE
(
        IN_R_ID	                VARCHAR2,				-- 예약아이디 입력
        IN_RC_DATE	        	DATE,					-- 취소날짜
        IN_RC_GUBUN	   			VARCHAR2,				-- 취소자 구분
        O_ERRCODE               OUT     VARCHAR2,
        O_ERRMSG                OUT      VARCHAR2
) AS
    V_NEW_ID        CHAR(5);
    V_R_ID_CNT      VARCHAR2(20);
	V_CHK_ID		CHAR(1);
    
    EXCEPT_R_ID          EXCEPTION;
	R_ID_EXCEPTION		 EXCEPTION;
  BEGIN

    -- 예약취소 테이블에 IN_R_ID 가 있는지 판단
    SELECT COUNT(R_ID)
    INTO V_R_ID_CNT
    FROM CANCLE_RESERVATION_TBL
    WHERE R_ID = IN_R_ID
  ;
	IF V_R_ID_CNT = 1 THEN 
		RAISE R_ID_EXCEPTION;
	END IF;

    -- 예약 테이블에 IN_R_ID 가 있는지 판단
    SELECT COUNT(R_ID)
    INTO V_R_ID_CNT
    FROM RESERVATION_TBL
    WHERE R_ID = IN_R_ID
  ;
    
    --예약 테이블에 IN_R_ID 가 있고 취소자가 호스트라면
    IF V_R_ID_CNT > 0 AND IN_RC_GUBUN = 'H' THEN
    
    SELECT  'RC' || TO_CHAR(TO_NUMBER(SUBSTR(NVL(MAX(RC_ID),'RC000'),3,3))+1,'FM000')
    INTO V_NEW_ID
    FROM CANCLE_RESERVATION_TBL;
    
    INSERT INTO CANCLE_RESERVATION_TBL(RC_ID,R_ID,RC_DATE,GUBUN)
    VALUES(V_NEW_ID, IN_R_ID,IN_RC_DATE,IN_RC_GUBUN);
    
	-- 호스트가 취소하면  RESERVATION_MANAGE_TBL 구분값 X로 업데이트
	MERGE INTO RESERVATION_MANAGE_TBL  A
	USING ( 
			SELECT T1.R_ID, T2.RM_ID
			FROM RESERVATION_TBL T1, RESERVATION_DETAIL_TBL T2
			WHERE T1.R_ID = T2.R_ID
			AND T1.R_ID = IN_R_ID
			)B
	ON(A.RM_ID = B.RM_ID)
	WHEN MATCHED THEN 
		UPDATE SET A.RM_GUBUN = 'X'
	;

    -- 회원이 취소한 거면 RESERVATION_MANAGE_TBL 그대로 유지
    ELSIF V_R_ID_CNT > 0 AND IN_RC_GUBUN = 'C' THEN
		SELECT  'RC' || TO_CHAR(TO_NUMBER(SUBSTR(NVL(MAX(RC_ID),'RC000'),3,3))+1,'FM000')
		INTO V_NEW_ID
		FROM CANCLE_RESERVATION_TBL;
		
		INSERT INTO CANCLE_RESERVATION_TBL(RC_ID,R_ID,RC_DATE,GUBUN)
		VALUES(V_NEW_ID, IN_R_ID,IN_RC_DATE,IN_RC_GUBUN);
		
	ELSE
    
        RAISE EXCEPT_R_ID;
    
    END IF;
    
    EXCEPTION
    WHEN EXCEPT_R_ID
    THEN
    O_ERRCODE:= 'ERR-102';
    O_ERRMSG := '없는 예약ID입니다';
	 ROLLBACK; 
	 
	WHEN R_ID_EXCEPTION THEN
	O_ERRCODE := ' ERR-103';
	O_ERRMSG := '이미 취소된 예약건입니다.';
	
     ROLLBACK; 
    WHEN OTHERS
    THEN O_ERRCODE := SQLCODE;
                O_ERRMSG := SQLERRM;
      ROLLBACK; 
    
  END PROC_INS_CANCLE;


PROCEDURE PROC_SEL_CANCLE
(       
        IN_RC_ID            VARCHAR2,
        IN_R_ID	            VARCHAR2,
        IN_RC_DATE	    VARCHAR2,
        IN_RC_GUBUN	    VARCHAR2,
        O_CURSOR        OUT     SYS_REFCURSOR
)AS

BEGIN

OPEN O_CURSOR FOR 
	SELECT D.RC_ID, D.R_ID, DECODE(GUBUN,'C','고객','호스트') AS 취소자, D.RC_DATE
			,C.CUST_ID, C.고객구분, C.CUST_NAME, C.CUST_TEL, C.MIN_DATE, C.MAX_DATE, C.R_PERSON, C.R_PRICE
	FROM 
		(
		SELECT A.R_ID, C.CUST_ID, DECODE(C.GUBUN,'C','회원','비회원') AS 고객구분, C.CUST_NAME, C.CUST_TEL
				,A.MIN_DATE, A.MAX_DATE, B.R_PERSON, B.R_PRICE, B.R_DATE
		FROM
			(
			SELECT T1.R_ID, MIN(RM_DATE) AS MIN_DATE, MAX(RM_DATE) AS MAX_DATE
			FROM RESERVATION_DETAIL_TBL T1, RESERVATION_MANAGE_TBL T2
			WHERE T1.RM_ID = T2.RM_ID
			GROUP BY T1.R_ID
			)A
		, RESERVATION_TBL B
		, CUSTOMER_TBL C
		WHERE A.R_ID = B.R_ID
		AND B.CUST_ID = C.CUST_ID
		ORDER BY A.R_ID
		)C
		, CANCLE_RESERVATION_TBL D
	WHERE C.R_ID = D.R_ID
	AND RC_ID LIKE '%' || IN_RC_ID || '%'
	AND D.R_ID LIKE '%' || IN_R_ID || '%'
	AND RC_DATE LIKE '%' || IN_RC_DATE || '%'
	AND GUBUN LIKE '%' || IN_RC_GUBUN || '%'
	
	;

END PROC_SEL_CANCLE;



PROCEDURE PROC_UP_CANCLE
(
        IN_RC_ID            	VARCHAR2,				-- 취소 아이디
        IN_RC_DATE	    		VARCHAR2,				-- 취소 날짜 
        IN_RC_GUBUN	    		VARCHAR2,				-- 취소자 구분
        O_ERRCODE               OUT     VARCHAR2,
        O_ERRMSG                OUT      VARCHAR2
)AS
		V_RC_ID_CNT      VARCHAR2(20);
		V_RM_ID                CHAR(5);
    
		EXCEPT_RC_ID            EXCEPTION;
BEGIN      

	-- IN_RC_ID가 존재하는 지 확인 
    SELECT COUNT(RC_ID)
    INTO V_RC_ID_CNT
    FROM CANCLE_RESERVATION_TBL
    WHERE RC_ID = IN_RC_ID
    ;
    
	-- IN_RC_ID가 존재한다면 
    IF V_RC_ID_CNT > 0 THEN
		-- IN_RC_ID를 가지는 데이터를 수정
        UPDATE CANCLE_RESERVATION_TBL
        SET RC_DATE = IN_RC_DATE,
                GUBUN = IN_RC_GUBUN
        WHERE RC_ID = IN_RC_ID
        ;
		
		-- 예약관리테이블의 구분값이 예약여부와 상관없다면 아래 삭제 
		-- 만약 취소자가 회원이라면
        IF (IN_RC_GUBUN = 'C') THEN
            
            
            MERGE INTO RESERVATION_MANAGE_TBL A
            USING (
					
                    SELECT T3.RM_ID
                    FROM CANCLE_RESERVATION_TBL T1, RESERVATION_DETAIL_TBL T2, RESERVATION_MANAGE_TBL T3
                    WHERE T1.RC_ID = IN_RC_ID 
                    AND T1.R_ID = T2.R_ID
                    AND T2.RM_ID = T3.RM_ID
                    AND T1.GUBUN = 'C'
                    )B
            ON(A.RM_ID = B.RM_ID)

            WHEN MATCHED THEN
			
            UPDATE 
            SET A.RM_GUBUN = 'O'
            ;
            
            /*
            FOR I IN  
            ( 
                 SELECT T3.RM_ID AS RMID
                  FROM CANCLE_RESERVATION_TBL T1, RESERVATION_DETAIL_TBL T2, RESERVATION_MANAGE_TBL T3
                  WHERE T1.RC_ID = IN_RC_ID 
                  AND T1.R_ID = T2.R_ID
                  AND T2.RM_ID = T3.RM_ID
                 AND T1.GUBUN = 'C'
            )
            LOOP
            
               UPDATE RESERVATION_MANAGE_TBL
                SET RM_GUBUN = 'O'
                WHERE RM_ID = I.RMID;
                
            END LOOP;
            
            */
                
        END IF;
   
        ELSE
            RAISE EXCEPT_RC_ID;

    END IF;
    
    EXCEPTION
    WHEN EXCEPT_RC_ID
    THEN
    O_ERRCODE:= 'ERR-102';
    O_ERRMSG := '없는 예약ID입니다';
    ROLLBACK;
    WHEN OTHERS
    THEN O_ERRCODE := SQLCODE;
    O_ERRMSG := SQLERRM;
    ROLLBACK;

END PROC_UP_CANCLE;



PROCEDURE PROC_DEL_CANCLE
(
        IN_RC_ID          				VARCHAR2,
        IN_R_ID	            			VARCHAR2,
        O_ERRCODE               OUT     VARCHAR2,
        O_ERRMSG                OUT     VARCHAR2
)AS
    V_RC_ID_CNT         VARCHAR2(20);
    V_R_ID_CNT         VARCHAR2(20);
    
    
     EXCEPT_RC_ID            EXCEPTION;
BEGIN

    -- 예약취소 아이디가 존재하는지
    SELECT COUNT(RC_ID)
    INTO V_RC_ID_CNT
    FROM CANCLE_RESERVATION_TBL
    WHERE RC_ID = IN_RC_ID
    ;
    
    -- 예약아이디가 예약취소테이블에 존재하는지?
    SELECT COUNT(R_ID)
    INTO V_R_ID_CNT
    FROM CANCLE_RESERVATION_TBL
    WHERE R_ID = IN_R_ID
    ;
    
	-- 만약 RC_ID가 존재하고, R_ID도 존재한다면
    IF (V_RC_ID_CNT > 0 AND V_R_ID_CNT > 0 )THEN
    
		-- 예약취소테이블 IN_R_ID 데이터 삭제
		DELETE FROM CANCLE_RESERVATION_TBL
		WHERE R_ID = IN_R_ID
		;
    
    ELSE 
    
		RAISE  EXCEPT_RC_ID;
    
    END IF;
    
     EXCEPTION 
     WHEN EXCEPT_RC_ID 
     THEN
    O_ERRCODE := 'ERR-102';
    O_ERRMSG := '예약취소 아이디가 존재하지 않습니다. ';


END PROC_DEL_CANCLE;

END PKG_CANCLE_RESERVATION;