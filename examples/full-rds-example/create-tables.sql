CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    label text NOT NULL,
    owner text NOT NULL,
    cost numeric(5,2) NOT NULL,
    time DATE NOT NULL DEFAULT current_timestamp
);

INSERT INTO product(label,owner,cost) VALUES ('Tee-shirt','textile-team',2.5);


CREATE TABLE Customer (
    id SERIAL PRIMARY KEY,
    firstname TEXT NOT NULL,
    lastname TEXT NULL,
    address TEXT NULL,
    time DATE NOT NULL DEFAULT current_timestamp
);

CREATE INDEX idx_Customer_lastname ON Customer(lastname);


CREATE TABLE Basket (
    id SERIAL PRIMARY KEY,
    customer_id int not null,
    product_id int not null,
    quantity int not null,
    CONSTRAINT fk_customer FOREIGN KEY(customer_id) REFERENCES Customer(id),
    CONSTRAINT fk_product FOREIGN KEY(product_id)  REFERENCES Product(id)
);

