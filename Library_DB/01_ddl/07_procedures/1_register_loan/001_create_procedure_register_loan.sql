-- =====================================================
-- PROCEDURE: sp_register_loan
-- Qué hace: Registra un préstamo de libro de forma segura.
-- Antes de insertar, valida que el libro y el usuario
-- existan, y que el libro esté disponible.
-- El trigger trg_update_book_availability se encarga
-- automáticamente de poner available = FALSE en book.
-- =====================================================

CREATE OR REPLACE PROCEDURE library.sp_register_loan(
    IN  p_book_id  UUID,    -- ID del libro que se quiere prestar
    IN  p_user_id  UUID,    -- ID del usuario que lo solicita
    OUT p_loan_id  UUID,    -- Retorna el ID del préstamo creado (NULL si hubo error)
    OUT p_message  VARCHAR  -- Retorna un mensaje de éxito o error
)
LANGUAGE plpgsql AS $$

DECLARE
    -- Variables locales para guardar resultados de las validaciones
    v_available   BOOLEAN;  -- Guarda si el libro está disponible o no
    v_book_exists BOOLEAN;  -- Guarda si el libro existe en la BD
    v_user_exists BOOLEAN;  -- Guarda si el usuario existe en la BD

BEGIN

    -- =====================================================
    -- VALIDACIÓN 1: ¿Existe el libro?
    -- EXISTS retorna TRUE si encuentra al menos 1 fila,
    -- FALSE si no encuentra nada.
    -- =====================================================
    SELECT EXISTS (
        SELECT 1
        FROM library.book
        WHERE book_id = p_book_id
    ) INTO v_book_exists;

    IF NOT v_book_exists THEN
        -- Si el libro no existe, salimos inmediatamente
        -- sin hacer nada más (RETURN corta la ejecución)
        p_loan_id := NULL;
        p_message := 'ERROR: Book not found.';
        RETURN;
    END IF;


    -- =====================================================
    -- VALIDACIÓN 2: ¿Existe el usuario?
    -- Misma lógica que la validación del libro
    -- =====================================================
    SELECT EXISTS (
        SELECT 1
        FROM library.user_account
        WHERE user_id = p_user_id
    ) INTO v_user_exists;

    IF NOT v_user_exists THEN
        p_loan_id := NULL;
        p_message := 'ERROR: User not found.';
        RETURN;
    END IF;


    -- =====================================================
    -- VALIDACIÓN 3: ¿Está disponible el libro?
    -- Traemos el valor de la columna "available" del libro
    -- para saber si alguien más ya lo tiene prestado
    -- =====================================================
    SELECT available
    INTO v_available
    FROM library.book
    WHERE book_id = p_book_id;

    IF NOT v_available THEN
        -- El libro existe pero ya está prestado
        p_loan_id := NULL;
        p_message := 'ERROR: Book is not available for loan.';
        RETURN;
    END IF;


    -- =====================================================
    -- ACCIÓN: Registrar el préstamo
    -- Si pasó las 3 validaciones, insertamos en loan.
    -- RETURNING loan_id INTO p_loan_id captura el UUID
    -- generado automáticamente y lo mete en p_loan_id
    -- para retornarlo al que llamó el procedure.
    --
    -- OJO: No tocamos book.available aquí — eso lo hace
    -- automáticamente el trigger trg_update_book_availability
    -- cuando detecta el INSERT en loan.
    -- =====================================================
    INSERT INTO library.loan (book_id, user_id, loan_date)
    VALUES (p_book_id, p_user_id, now())
    RETURNING loan_id INTO p_loan_id;

    p_message := 'SUCCESS: Loan registered successfully.';


-- =====================================================
-- MANEJO DE ERRORES INESPERADOS
-- Si algo explota que no anticipamos (error de BD,
-- conexión, etc.), capturamos el error con WHEN OTHERS,
-- retornamos NULL y el mensaje de error real con SQLERRM
-- =====================================================
EXCEPTION
    WHEN OTHERS THEN
        p_loan_id := NULL;
        p_message := 'ERROR: Unexpected error - ' || SQLERRM;
        -- SQLERRM es la variable de PostgreSQL que contiene
        -- el mensaje del último error ocurrido

END;
$$;