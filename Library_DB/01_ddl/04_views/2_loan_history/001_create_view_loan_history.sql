-- Historiales de prestamos

CREATE OR REPLACE VIEW library.vw_loan_history 
AS SELECT 
l.loan_id,
u.name  AS user_name,
u.email AS user_email,
b.title AS book_title,
b.author AS book_author,
c.name AS category_name,
l.loan_date, 
l.return_date,

CASE WHEN l.return_date IS NULL THEN 'ACTIVE' ELSE 'RETURNED'

END AS loan_status
FROM library.loan l 
INNER JOIN library.user_account u ON l.user_id = u.user_id
INNER JOIN library.book b  ON l.book_id = b.book_id
LEFT JOIN library.category c  ON b.category_id = c.category_id
ORDER BY l.loan_date DESC;