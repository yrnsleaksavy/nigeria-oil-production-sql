select *
from NigeriaOilProject..productiontable$

--Changed data layout so months became rows instead of columns.
---- Makes it easier to query, sort, and analyze in SQL.


select *
from NigeriaOilProject..productiontable$
unpivot
(
PRODUCTION FOR MONTH IN ([JANUARY], [FEBRUARY], [MARCH], [APRIL], [MAY], [JUNE], [JULY])
) AS unpvt

--created anew table

DROP TABLE NigeriaOilProject..TerminalOilProduction;

SELECT 
    [TERMINAL/STREAM] AS TERMINAL,
    UPPER([Liquid Type]) AS LIQUID_TYPE,
    MONTH,
    production AS VOLUME
INTO NigeriaOilProject..TerminalOilProduction
FROM NigeriaOilProject..productiontable$
UNPIVOT
(
    production FOR MONTH IN ([JANUARY], [FEBRUARY], [MARCH], [APRIL], [MAY], [JUNE], [JULY])
) AS unpvt;

--view table

SELECT *
FROM NigeriaOilProject..TerminalOilProduction;

--Which month had the highest oil production in the past months

SELECT TOP 1 MONTH, VOLUME, TERMINAL
FROM NigeriaOilProject..TerminalOilProduction
WHERE LIQUID_TYPE = 'CRUDE OIL'
ORDER BY VOLUME DESC;

--highest production across terminal

SELECT TERMINAL,
       LIQUID_TYPE,
       MONTH,
       VOLUME
FROM NigeriaOilProject..TerminalOilProduction t1
WHERE VOLUME = (
        SELECT MAX(VOLUME)
        FROM NigeriaOilProject..TerminalOilProduction T2
        WHERE t2.TERMINAL = t1.TERMINAL
        AND t2.LIQUID_TYPE = t1.LIQUID_TYPE
        )
ORDER BY TERMINAL, LIQUID_TYPE;

--highest production volume overall

SELECT TOP 1 TERMINAL, LIQUID_TYPE, MONTH, VOLUME
FROM NigeriaOilProject..TerminalOilProduction
ORDER BY VOLUME DESC;

--Which terminal (or region) contributes the most to export volumes?

SELECT TERMINAL,
       SUM (VOLUME) AS TOTAL_EXPORT
       FROM NigeriaOilProject..TerminalOilProduction
       WHERE TERMINAL IS NOT NULL
        AND TERMINAL NOT LIKE '%Total%'
        AND TERMINAL NOT LIKE '%Daily Average%'
       GROUP BY TERMINAL
       ORDER BY TOTAL_EXPORT DESC;
       