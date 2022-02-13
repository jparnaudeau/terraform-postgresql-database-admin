CREATE TABLE product (
    id SERIAL PRIMARY KEY,
    label TEXT NOT NULL,
    owner TEXT NOT NULL,
    cost NUMERIC(5,2) NOT NULL,
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
    customer_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    CONSTRAINT fk_customer FOREIGN KEY(customer_id) REFERENCES Customer(id),
    CONSTRAINT fk_product FOREIGN KEY(product_id)  REFERENCES Product(id)
);

CREATE TABLE Stats(
    id SERIAL PRIMARY KEY,
    product TEXT NOT NULL,
    value NUMERIC(8,2)
);
