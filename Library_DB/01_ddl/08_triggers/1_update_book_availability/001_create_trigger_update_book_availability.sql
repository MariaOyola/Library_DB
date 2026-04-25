-- La idea del trigger es que, cada vez que se inserta un prestamo
-- en "loan", el trigger pone available = FALSE en book.
-- Cuando se actualiza "return_date" (devolución), pone available = TRUE.


-- Función que ejecuta el trigger
CREATE OR REPLACE FUNCTION library.fn_update_book_availability()
RETURNS TRIGGER AS $$
BEGIN

    -- INSERT: se crea un prestamo -> libro no disponible
    IF (TG_OP = 'INSERT') THEN   -- INSERT / se creó un prestamo (cuando alguien pide el libro)
        UPDATE library.book
        SET available = FALSE,   -- El libro queda como No disponible
            updated_at = now()
        WHERE book_id = NEW.book_id;

    -- UPDATE: se registra devolucion (return_date deja de ser NULL) -> libro disponible
    ELSIF (TG_OP = 'UPDATE') THEN  -- UPDATE / se modificó un préstamo
        IF OLD.return_date IS NULL AND NEW.return_date IS NOT NULL THEN  -- solo cambia cuando se registra la devolución
            UPDATE library.book
            SET available = TRUE,    -- El libro vuelve a estar disponible
                updated_at = now()
            WHERE book_id = NEW.book_id;
        END IF;  -- <-- aquí estaba el punto "." en vez de ";"
    END IF;

    RETURN NEW;  -- Devuelve el registro actualizado
END;
$$ LANGUAGE plpgsql;


-- Trigger que llama la función
CREATE OR REPLACE TRIGGER trg_update_book_availability
AFTER INSERT OR UPDATE ON library.loan  -- se ejecuta después del cambio
FOR EACH ROW
EXECUTE FUNCTION library.fn_update_book_availability();

-- INSERT OR UPDATE  (en creación o modificación)
-- ON library.loan   (en la tabla de préstamos)
-- FOR EACH ROW      (por cada fila afectada)