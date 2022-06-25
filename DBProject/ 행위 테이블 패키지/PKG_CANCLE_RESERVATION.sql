create or replace NONEDITIONABLE PACKAGE PKG_CANCLE_RESERVATION AS 

PROCEDURE PROC_INS_CANCLE
(
        IN_R_ID	                VARCHAR2,
        IN_RC_DATE	        DATE,
        IN_RC_GUBUN	    VARCHAR2,
        O_ERRCODE               OUT     VARCHAR2,
        O_ERRMSG                OUT      VARCHAR2
);

PROCEDURE PROC_SEL_CANCLE
(       
        IN_RC_ID            VARCHAR2,
        IN_R_ID	            VARCHAR2,
        IN_RC_DATE	    VARCHAR2,
        IN_RC_GUBUN	    VARCHAR2,
        O_CURSOR        OUT     SYS_REFCURSOR
);


PROCEDURE PROC_UP_CANCLE
(
        IN_RC_ID            VARCHAR2,
        IN_RC_DATE	    VARCHAR2,
        IN_RC_GUBUN	    VARCHAR2,
         O_ERRCODE               OUT     VARCHAR2,
        O_ERRMSG                OUT      VARCHAR2
);

PROCEDURE PROC_DEL_CANCLE
(
        IN_RC_ID          		VARCHAR2,
        IN_R_ID	            	VARCHAR2,
        O_ERRCODE               OUT     VARCHAR2,
        O_ERRMSG                OUT      VARCHAR2
);


END PKG_CANCLE_RESERVATION;