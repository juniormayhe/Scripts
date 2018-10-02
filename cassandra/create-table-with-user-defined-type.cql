CREATE TABLE wishlist (
	id uuid,
	user_id int,
	tenant_id int,
	created_at timestamp,
	PRIMARY KEY (id)
);

CREATE TYPE wishlistitem (
	id uuid,
	product_id uuid,
	quantity int,
	product_name text,
	created_at timestamp,
	updated_at timestamp
);

--frozen is added to wishlist table as user defined column https://docs.datastax.com/en/cql/3.1/cql/cql_reference/create_table_r.html
ALTER TABLE wishlist
add wishlistitems frozen<List<wishlistitem>>;
