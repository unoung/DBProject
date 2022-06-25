/*
	1. 고객이 볼수있는 예약 가능 목록
	2. 호스트별 총 결제 금액 목록
	3. 숙소별 총 결제 금액 목록
	4. 지역을 포함한 예약 관리 목록
	5. 지역 및 편의시설을 포함한 방 목록
	6. 취소 여부 포함하지 않은 예약 목록 
	7. 예약 취소 목록
	8. 숙소 정보 목록 (1)(2)
	9. 숙소별 예약 현황 목록
	10. 예약된 방 중 1박 가격이 가장 높은 방
	11. 예약을 한 번도 하지 않은 회원 목록
	12. 고객별 예약되었던 예약 건 총 금액 목록
	13. 고객별 예약완료된 총 금액 목록
	14. 고객별 예약 횟수, 취소횟수 목록
	15. 건물별 예약 횟수, 고객 취소 횟수 
	16. 지역별 건물 별점 평균
	17. 예약된 건물과 예약 안된 건물
	18. 호스트가 취소한 예약 목록 중 최대 연박 예약 건
*/



--고객이 볼수있는 예약 가능 목록
SELECT T1.RM_ID, T1.ROOM_ID, T1.RM_DATE, T1.RM_PRICE, T1.RM_PERSON, T1.RM_ADD_PERSON, T1.RM_ADD_PRICE
FROM RESERVATION_MANAGE_TBL T1, RESERVATION_DETAIL_TBL T2
WHERE T1.RM_ID = T2.RM_ID(+) 
  AND T2.R_GUBUN IS NULL 
  AND T1.RM_GUBUN = 'O'
ORDER BY T1.RM_DATE ASC, T1.RM_ID ASC;

--호스트 별 총 결제 금액 목록
SELECT C.HOST_ID,C.HOST_NAME, SUM(NVL(D.R_PRICE, 0))AS TLTPRICE FROM
(
    SELECT A.HOST_ID,A.L_ID,A.HOST_NAME,A.L_NAME,B.RM_ID,B.ROOM_ID FROM
    (
        SELECT T1.HOST_ID,T2.L_ID,T1.HOST_NAME,T2.L_NAME FROM HOST_TBL T1, LODGING_TBL T2
        WHERE T1.HOST_ID = T2.HOST_ID(+)
    )A
    ,
    (
        SELECT T1.RM_ID,T1.ROOM_ID,T1.RM_DATE,T1.RM_GUBUN,T1.RM_PRICE,T1.RM_PERSON,T1.RM_ADD_PERSON,T1.RM_ADD_PRICE,T2.L_ID
        FROM RESERVATION_MANAGE_TBL T1,ROOM_TBL T2
        WHERE T1.ROOM_ID(+) =  T2.ROOM_ID
    )B
        WHERE A.L_ID = B.L_ID
)C,
(
    SELECT A.RM_ID,A.ROOM_ID,R_PRICE FROM 
    (
        SELECT T1.RM_ID,T1.ROOM_ID 
		FROM RESERVATION_MANAGE_TBL T1, RESERVATION_DETAIL_TBL T2
        WHERE T1.RM_ID = T2.RM_ID(+) 
    )A,
    (
        SELECT T1.RM_ID,T2.R_PRICE 
		FROM RESERVATION_DETAIL_TBL T1,RESERVATION_TBL T2
        WHERE T1.R_ID(+) = T2.R_ID AND T1.R_GUBUN IS NULL
    )B
    WHERE A.RM_ID = B.RM_ID(+)
)D
WHERE C.RM_ID = D.RM_ID(+)
GROUP BY C.HOST_ID,C.HOST_NAME
ORDER BY C.HOST_ID,C.HOST_NAME ASC;


-- 숙소 별 총 결제 금액 목록
SELECT C.L_ID,C.L_NAME, SUM(NVL(D.R_PRICE, 0))AS TLTPRICE FROM
(
    SELECT A.L_ID,A.L_NAME,B.RM_ID 
    FROM LODGING_TBL A
    ,
    (
        SELECT T1.RM_ID,T1.ROOM_ID,T1.RM_DATE,T1.RM_GUBUN,T1.RM_PRICE,T1.RM_PERSON,T1.RM_ADD_PERSON,T1.RM_ADD_PRICE,T2.L_ID
        FROM RESERVATION_MANAGE_TBL T1,ROOM_TBL T2
        WHERE T1.ROOM_ID(+) =  T2.ROOM_ID
    )B
        WHERE A.L_ID = B.L_ID(+)
)C,
(
    SELECT A.RM_ID,A.ROOM_ID,R_PRICE FROM 
    (
        SELECT T1.RM_ID,T1.ROOM_ID 
		FROM RESERVATION_MANAGE_TBL T1, RESERVATION_DETAIL_TBL T2
        WHERE T1.RM_ID = T2.RM_ID(+) 
    )A,
    (
        SELECT T1.RM_ID,T2.R_PRICE 
		FROM RESERVATION_DETAIL_TBL T1,RESERVATION_TBL T2
        WHERE T1.R_ID(+) = T2.R_ID AND T1.R_GUBUN IS NULL
    )B
    WHERE A.RM_ID = B.RM_ID(+)
)D
WHERE C.RM_ID = D.RM_ID(+)
GROUP BY C.L_ID,C.L_NAME
ORDER BY C.L_ID,C.L_NAME ASC;



-- 지역을 포함한 예약관리 목록
SELECT A2.RM_ID, A2.ROOM_ID, A1.L_ID, A1.L_NAME, A1.COMVAL1, A1.COMVAL2, 
	    A2.RM_DATE, A2.RM_GUBUN, A2.RM_PRICE, A2.RM_PERSON, A2.RM_ADD_PERSON, A2.RM_ADD_PRICE
FROM
(
    SELECT A.L_ID,A.L_NAME,B.COMVAL1,B.COMVAL2,A.ROOM_ID 
	FROM 
    ( 
        SELECT T1.L_ID,T1.G_GRP_ID,G_COM_ID,G_COM_ID2,T2.ROOM_ID,T1.L_NAME 
		FROM LODGING_TBL T1, ROOM_TBL T2
        WHERE T1.L_ID = T2.L_ID
    )A,
    (
        SELECT T1.GRP_ID,T1.COM_ID AS COMID1,T2.COM_ID AS COMID2 , 
                    T1.COM_VAL AS COMVAL1, T2.COM_VAL AS COMVAL2
        FROM COMMONS_TBL T1,COMMONS_TBL T2
        WHERE T1.GRP_ID = T2.GRP_ID(+) 
        AND T1.COM_ID = T2.PARENT_ID(+) 
        AND T1.COM_LVL = 1 AND T1.GRP_ID = 'GRP001'
    )B
    WHERE A.G_GRP_ID = B.GRP_ID 
	  AND A.G_COM_ID = B.COMID1 
	  AND A.G_COM_ID2 = B.COMID2
)A1,
(
    SELECT T1.RM_ID,T1.ROOM_ID,T1.RM_DATE,T1.RM_GUBUN,T1.RM_PRICE,T1.RM_PERSON,T1.RM_ADD_PERSON,T1.RM_ADD_PRICE 
    FROM RESERVATION_MANAGE_TBL T1,ROOM_TBL T2
    WHERE T1.ROOM_ID(+) =  T2.ROOM_ID
)A2
WHERE A1.ROOM_ID = A2.ROOM_ID;


-- 지역 및 편의시설을 포함한 방 목록
SELECT A2.ROOM_ID, A1.L_ID, A1.L_NAME, A1.COMVAL1, A1.COMVAL2,
	    A2.BED, A2.BEDROOM, A2.BATH, A2.GRP_VAL, A2.COM_VAL
FROM
(
    SELECT A.L_ID,A.L_NAME,B.COMVAL1,B.COMVAL2,A.ROOM_ID 
	FROM 
    ( 
        SELECT T1.L_ID,T1.G_GRP_ID,G_COM_ID,G_COM_ID2,T2.ROOM_ID,T1.L_NAME 
		FROM LODGING_TBL T1, ROOM_TBL T2
        WHERE T1.L_ID = T2.L_ID
    )A,
    (
        SELECT T1.GRP_ID,T1.COM_ID AS COMID1,T2.COM_ID AS COMID2 , 
                      T1.COM_VAL AS COMVAL1, T2.COM_VAL AS COMVAL2
        FROM COMMONS_TBL T1,COMMONS_TBL T2
        WHERE T1.GRP_ID = T2.GRP_ID(+) 
        AND T1.COM_ID = T2.PARENT_ID(+) 
        AND T1.COM_LVL = 1 AND T1.GRP_ID = 'GRP001'
    )B
    WHERE A.G_GRP_ID = B.GRP_ID AND A.G_COM_ID = B.COMID1 AND A.G_COM_ID2 = B.COMID2
)A1,
(
    SELECT B.ROOM_ID,B.L_ID,B.BED,B.BEDROOM,B.BATH,A.GRP_VAL,A.COM_VAL 
	FROM 
    (
        SELECT T2.ROOM_ID,T1.GRP_VAL,T1.COM_VAL 
		FROM  COMMONS_TBL T1 , ROOM_DETAIL_TBL T2
        WHERE T1.GRP_ID = T2.GRP_ID AND T1.COM_ID = T2.COM_ID  
		  AND T1.COM_LVL = 1 AND T1.GRP_ID = 'GRP003'
    )A, ROOM_TBL B
    WHERE A.ROOM_ID(+) = B.ROOM_ID
)A2
WHERE A1.ROOM_ID = A2.ROOM_ID(+)
-- AND A1.COMVAL1 LIKE '%지역명 입력%'  AND A2.COM_VAL  LIKE '%편의시설명 입력%' 검색 입력
;


-- 취소 여부 포함하지 않은 예약 목록 
SELECT A.R_ID, C.CUST_ID, DECODE(C.GUBUN,'C','회원','비회원') AS 고객구분, C.CUST_NAME, C.CUST_TEL
      ,A.MIN_DATE, A.MAX_DATE, B.R_PERSON, TO_CHAR(B.R_PRICE,'FM999,999')AS TLTPRICE, TO_CHAR(B.R_DATE, 'YY/MM/DD HH24:MI') AS R_TIME
FROM
   (
   SELECT T1.R_ID
			,MIN(RM_DATE) AS MIN_DATE
			,MAX(RM_DATE) AS MAX_DATE
   FROM RESERVATION_DETAIL_TBL T1, RESERVATION_MANAGE_TBL T2
   WHERE T1.RM_ID = T2.RM_ID
   GROUP BY T1.R_ID
   )A
   , RESERVATION_TBL B
   , CUSTOMER_TBL C
   WHERE A.R_ID = B.R_ID
   AND B.CUST_ID = C.CUST_ID
   ORDER BY A.R_ID
;

-- 예약 취소 목록 (1)
SELECT D.RC_ID, D.R_ID, DECODE(GUBUN,'C','고객','호스트') AS 취소자, D.RC_DATE
      ,C.CUST_ID, C.고객구분, C.CUST_NAME, C.CUST_TEL, C.MIN_DATE, C.MAX_DATE, C.R_PERSON, TO_CHAR(C.R_PRICE,'FM999,999') AS TLTPRICE
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
;
	
-- 숙소 정보 목록
SELECT A.L_ID, D.HOST_ID, D.HOST_NUM, D.HOST_NAME, D.HOST_LVL, D.LVL_VAL
      , A.L_NAME, B.P_ID, B.P_VAL, B.COM_ID, B.COM_VAL, C.P_ID, C.P_VAL, C.COM_ID, C.COM_VAL
      ,A.L_SCOPE, A.CHECKIN_TIME, A.CHECKOUT_TIME
FROM LODGING_TBL A,
   (-- 지역 구하기
   SELECT T1.COM_ID AS P_ID, T1.COM_VAL AS P_VAL, T2.COM_ID, T2.COM_VAL
   FROM COMMONS_TBL T1, COMMONS_TBL T2
   WHERE T1.GRP_ID = 'GRP001' 
   AND T1.GRP_ID = T2.GRP_ID
   AND T1.COM_ID = T2.PARENT_ID
   AND T1.COM_VAL != 'ROOT'
   )B,
   (-- 건물유형 구하기 
   SELECT T1.COM_ID AS P_ID, T1.COM_VAL AS P_VAL, T2.COM_ID, T2.COM_VAL
   FROM COMMONS_TBL T1, COMMONS_TBL T2
   WHERE T1.GRP_ID = 'GRP002'
   AND T1.GRP_ID = T2.GRP_ID
   AND T1.COM_ID = T2.PARENT_ID
   AND T1.COM_VAL != 'ROOT'
   )C,
   (
   SELECT T1.HOST_ID, T1.HOST_NAME, T1.HOST_NUM, T1.HOST_LVL, T2.COM_VAL AS LVL_VAL
   FROM HOST_TBL T1, COMMONS_TBL T2
   WHERE T2.GRP_ID = 'GRP004'
   AND T1.HOST_LVL = T2.COM_ID
   )D
WHERE A.G_COM_ID2 = B.COM_ID
AND A.L_COM_ID2 = C.COM_ID
AND A.HOST_ID = D.HOST_ID
;

-- 숙소 정보 목록 (2)
SELECT T1.L_ID, T1.L_NAME, T6.HOST_NAME, T1.L_SCOPE,T2.COM_VAL, T3.COM_VAL,T4.COM_VAL,
		T5.COM_VAL,T1.CHECKIN_TIME,T1.CHECKOUT_TIME
FROM LODGING_TBL T1, COMMONS_TBL T2, 
    COMMONS_TBL T3, COMMONS_TBL T4, COMMONS_TBL T5, HOST_TBL T6
WHERE T1.G_GRP_ID = T2.GRP_ID AND T1.G_COM_ID = T2.COM_ID
    AND T1.G_GRP_ID = T3.GRP_ID AND T1.G_COM_ID2 = T3.COM_ID
    AND T1.L_GRP_ID = T4.GRP_ID AND T1.L_COM_ID = T4.COM_ID
    AND T1.L_GRP_ID = T5.GRP_ID AND T1.L_COM_ID2 = T5.COM_ID
    AND T1.HOST_ID = T6.HOST_ID
ORDER BY T1.L_ID ASC
;
	
	
-- 숙소별 예약 현황 목록
SELECT T1.L_ID, T1.L_NAME, T2.ROOM_ID, T5.R_ID
    FROM LODGING_TBL T1,ROOM_TBL T2, RESERVATION_MANAGE_TBL T3, RESERVATION_DETAIL_TBL T4, RESERVATION_TBL T5
WHERE T1.L_ID = T2.L_ID
    AND T2.ROOM_ID = T3.ROOM_ID
    AND T3.RM_ID = T4.RM_ID
    AND T4.R_ID = T5.R_ID
GROUP BY  T1.L_ID, T1.L_NAME, T2.ROOM_ID, T5.R_ID
ORDER BY T1.L_ID ASC
    ; 
    
--  예약된 방 중 1박 가격이 가장 높은 방
SELECT  ROOM_ID, PRICE, RNK FROM
    (
    SELECT T1.ROOM_ID, MAX(T1.RM_PRICE) AS PRICE, RANK() OVER(ORDER BY  MAX(T1.RM_PRICE) DESC) AS RNK
    FROM RESERVATION_MANAGE_TBL T1, RESERVATION_DETAIL_TBL T2
    WHERE T1.RM_ID = T2.RM_ID
    GROUP BY T1.ROOM_ID
    )
WHERE RNK = 1
;

-- 예약을 한 번도 하지 않은 회원 목록
SELECT T1.CUST_ID, T1.CUST_NAME, T1.CUST_TEL, T1.GUBUN 
FROM CUSTOMER_TBL T1, RESERVATION_TBL T2, RESERVATION_DETAIL_TBL T3, RESERVATION_MANAGE_TBL T4
WHERE T1.CUST_ID = T2.CUST_ID(+)
	AND T2.R_ID = T3.R_ID(+)
	AND T3.RM_ID = T4.RM_ID(+)
	AND T2.R_ID IS NULL
;


-- 고객별 예약되었던 예약 건 총 금액 목록
SELECT T1.CUST_ID, T1.CUST_NAME, T1.CUST_TEL, DECODE(T1.GUBUN,'C','회원','비회원')AS 회원구분, TO_CHAR(SUM(T2.R_PRICE) , 'FM999,999,999')AS TLTPRICE
FROM CUSTOMER_TBL T1, RESERVATION_TBL T2, RESERVATION_DETAIL_TBL T3, RESERVATION_MANAGE_TBL T4
WHERE T1.CUST_ID = T2.CUST_ID(+)
	AND T2.R_ID = T3.R_ID(+)
	AND T3.RM_ID = T4.RM_ID(+)
	AND T4.RM_GUBUN = 'O'
	AND T3.R_GUBUN IS NULL
GROUP BY T1.CUST_ID, T1.CUST_NAME, T1.CUST_TEL, T1.GUBUN
;

-- 고객별 예약완료된 총 금액 목록
SELECT A.CUST_ID, A.CUST_NAME, A.CUST_TEL, DECODE(A.GUBUN,'C','회원','비회원') AS 회원구분, NVL(TO_CHAR(SUM(B.R_PRICE),'FM999,999,999'),0) AS TLTPRICE
FROM CUSTOMER_TBL A,
	(
	SELECT T1.CUST_ID, T1.R_PRICE
	FROM RESERVATION_TBL T1, RESERVATION_DETAIL_TBL T2, CANCLE_RESERVATION_TBL T3
	WHERE T1.R_ID = T2.R_ID
	AND T1.R_ID = T3.R_ID(+)
	AND T2.R_GUBUN IS NULL
	AND T3.GUBUN IS NULL
	GROUP BY T1.CUST_ID, T1.R_PRICE
	)B
WHERE A.CUST_ID = B.CUST_ID(+)
GROUP BY A.CUST_ID, A.CUST_NAME, A.CUST_TEL, DECODE(A.GUBUN,'C','회원','비회원')
ORDER BY A.CUST_ID
;

-- 고객 별 예약 횟수, 취소횟수 목록
SELECT A.CUST_ID, A.CUST_NAME, A.CUST_TEL
	 , COUNT(B.R_ID)AS R_CNT, SUM(NVL(B.C_CANCEL,0)) AS C_CNT
FROM CUSTOMER_TBL A,
(
	SELECT T1.R_ID, T1.CUST_ID, DECODE(T3.GUBUN,'C', 1, 0) AS C_CANCEL
	FROM RESERVATION_TBL T1, RESERVATION_DETAIL_TBL T2, CANCLE_RESERVATION_TBL T3
	WHERE T1.R_ID = T2.R_ID 
	AND T1.R_ID = T3.R_ID(+)
	GROUP BY T1.R_ID, T1.CUST_ID, DECODE(T3.GUBUN,'C', 1, 0) 
	ORDER BY T1.R_ID
)B
WHERE A.CUST_ID = B.CUST_ID(+)
GROUP BY A.CUST_ID, A.CUST_NAME, A.CUST_TEL
ORDER BY A.CUST_ID
;

-- 건물 별 예약 횟수, 고객 취소 횟수
SELECT B.L_ID, B.L_NAME, COUNT(C.R_ID)AS R_CNT, SUM(DECODE(C.C_CNT,'C',1,0)) AS C_CNT
FROM ROOM_TBL A, LODGING_TBL B,
(
	SELECT MAX(T1.R_ID) AS R_ID, MAX(T1.CUST_ID) AS CUST_ID, MAX(T4.ROOM_ID) AS ROOM_ID, MAX(T3.GUBUN)AS C_CNT
	FROM RESERVATION_TBL T1, RESERVATION_DETAIL_TBL T2, CANCLE_RESERVATION_TBL T3, RESERVATION_MANAGE_TBL T4
	WHERE T1.R_ID = T2.R_ID 
	AND T1.R_ID = T3.R_ID(+)
	AND T2.RM_ID = T4.RM_ID
	GROUP BY T1.R_ID
	ORDER BY T1.R_ID
)C
WHERE A.ROOM_ID = C.ROOM_ID(+)
AND A.L_ID(+) = B.L_ID
GROUP BY B.L_ID, B.L_NAME, B.L_SCOPE
ORDER BY B.L_ID
;

-- 지역별 건물 별점 평균 목록
SELECT B.COM_VAL, B.COM_VAL2, NVL(ROUND(SUM(A.L_SCOPE)/COUNT(L_ID),2),0)AS AVG_SCOPE
FROM LODGING_TBL A,
	(
	SELECT T2.COM_ID, T2.COM_VAL, T1.COM_ID AS COM_ID2, T1.COM_VAL AS COM_VAL2
	FROM COMMONS_TBL T1, COMMONS_TBL T2
	WHERE T1.PARENT_ID = T2.COM_ID
	AND T1.GRP_ID = 'GRP001'
	AND T1.GRP_ID = T2.GRP_ID
	AND T2.COM_ID != 'COM000'
	)B
WHERE A.G_COM_ID2(+) = B.COM_ID2
GROUP BY B.COM_VAL, B.COM_VAL2
ORDER BY B.COM_VAL, B.COM_VAL2 ASC
;

-- 예약된 건물과 예약 안된 건물 
 SELECT A.L_ID , COUNT(RID)
 FROM LODGING_TBL A,
 (
 SELECT T1.R_ID AS RID,T5.L_ID
 FROM RESERVATION_TBL T1, RESERVATION_DETAIL_TBL T2, RESERVATION_MANAGE_TBL T3, ROOM_TBL T4,LODGING_TBL T5
 WHERE T1.R_ID= T2.R_ID
 AND T2.RM_ID = T3.RM_ID
 AND T3.ROOM_ID = T4.ROOM_ID
 AND T4.L_ID= T5.L_ID
GROUP BY  T1.R_ID, T5.L_ID
)B
WHERE A.L_ID = B.L_ID(+)
GROUP BY A.L_ID
ORDER BY A.L_ID ASC
;

-- 호스트가 취소한 예약 목록 중 최대 연박 예약 건
SELECT R_ID, DATE_CNT, MIN_DATE, MAX_DATE
FROM
(
	SELECT T2.R_ID, COUNT(T1.RM_ID) AS DATE_CNT, MIN(T1.RM_DATE) AS MIN_DATE, MAX(T1.RM_DATE) AS MAX_DATE
			,DENSE_RANK() OVER(ORDER BY COUNT(T1.RM_ID) DESC) AS RNK
	FROM RESERVATION_MANAGE_TBL T1, RESERVATION_DETAIL_TBL T2, CANCLE_RESERVATION_TBL T3
	WHERE T1.RM_ID = T2.RM_ID
	AND T2.R_ID = T3.R_ID
	AND T3.GUBUN = 'H'
	GROUP BY T2.R_ID
)
WHERE RNK = 1	
;