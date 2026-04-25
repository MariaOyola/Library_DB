CREATE TABLE library.loan (
    loan_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    book_id UUID NOT NULL,
    user_id UUID NOT NULL,

    loan_date TIMESTAMPTZ NOT NULL DEFAULT now(),
    return_date TIMESTAMPTZ,

    CONSTRAINT fk_loan_book
        FOREIGN KEY (book_id)
        REFERENCES library.book(book_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_loan_user
        FOREIGN KEY (user_id)
        REFERENCES library.user_account(user_id)
        ON DELETE CASCADE,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Un libro puede tener muchos prestamos y un prestamo pertenece a un libro (1:N)
-- Un usuario puede pedir muchos libros y un libro puede ser prestado a muchos usuarios (N:M) 

 