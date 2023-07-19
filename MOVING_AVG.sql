SELECT *
	, AVG(REVENUE) OVER (ORDER BY DATETIME ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS MOVING_AVG
FROM REVENUES

/* gitHub:

git status
git add -M(click Tab to see full name; M for first name)
git add --all or -A

*/