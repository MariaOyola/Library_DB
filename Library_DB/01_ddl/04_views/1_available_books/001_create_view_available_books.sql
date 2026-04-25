--- ver los libros disponibles en su categoria

CREATE OR REPLACE VIEW library.vw_available_books 
AS 
SELECT b.book_id,
       b.title,
       b.author,
       b.isbn,
       c.name AS category_name 
FROM library.book b 
LEFT JOIN library.category c
       ON b.category_id = c.category_id
WHERE b.available = TRUE
ORDER BY b.title;
