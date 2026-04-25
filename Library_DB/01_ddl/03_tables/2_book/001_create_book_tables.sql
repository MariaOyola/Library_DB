CREATE TABLE library.book ( 
    book_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(150) NOT NULL,
    author VARCHAR(100) NOT NULL,
    isbn VARCHAR(20) UNIQUE,
    available BOOLEAN NOT NULL DEFAULT TRUE,  --disponible

    category_id UUID,
    CONSTRAINT fk_book_category
        FOREIGN KEY (category_id)
        REFERENCES library.category(category_id)
        ON DELETE SET NULL,

    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Una Categoria puede tener muchos libros y un libro puede tener solo una categoria (1:N)