--- DATABASE BUILDING STEP ---

--Settings
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;

--Check Reach
DECLARE @Result INT;
EXEC xp_fileexist 'C:\SUMUPFILES\device.xlsx', @Result OUTPUT;
SELECT @Result;

--Table Creation: Store
CREATE TABLE Store (
    store_id INT NOT NULL PRIMARY KEY, --Changed to avoid ambiguity issues
	store_name VARCHAR(255) NOT NULL, --Changed to avoid using reserved word
    store_address VARCHAR(255) NOT NULL, --Changed to avoid using reserved word
	city VARCHAR(255) NOT NULL,
	country VARCHAR(255) NOT NULL,
	created_at DATETIME NOT NULL,
	typology VARCHAR(255) NOT NULL,
	customer_id INT NOT NULL
);
CREATE UNIQUE INDEX index_store
ON Store (store_id);

--File Insert: Store
INSERT INTO Store (store_id, store_name, store_address, city, country, created_at, typology, customer_id)
SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0', 
    'Excel 12.0;Database=C:\SUMUPFILES\store.xlsx;HDR=YES;IMEX=1',
    'SELECT * FROM [store.csv$]'
);

--Check Table: Store
SELECT * FROM Store;

--Table Creation: Device
CREATE TABLE Device (
    device_id INT NOT NULL PRIMARY KEY, --Changed to avoid ambiguity issues and to match Transactions table
    device_type INT NOT NULL, 
    store_id INT NOT NULL FOREIGN KEY REFERENCES Store(store_id)
);
CREATE UNIQUE INDEX index_device
ON Device (device_id);

--File Insert: Device
INSERT INTO Device (device_id, device_type, store_id)
SELECT * 
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;Database=C:\SUMUPFILES\device.xlsx;HDR=YES;IMEX=1',
    'SELECT * FROM [device.csv$]'
);

--Check Table: Device
SELECT * FROM Device;

--Tables Creation: Transactions

CREATE TABLE Transactions ( --Changed to avoid using reserved word
    tr_id INT NOT NULL PRIMARY KEY, --Changed to avoid ambiguity issues
    device_id INT NOT NULL FOREIGN KEY REFERENCES Device(device_id),
    product_name VARCHAR(255) NOT NULL,
	product_sku VARCHAR(255) NOT NULL,
	category_name VARCHAR(255) NOT NULL,
	amount BIGINT NOT NULL,
	tr_status VARCHAR(255) NOT NULL, --Changed to avoid using reserved word
	card_number BIGINT NOT NULL,
	cvv SMALLINT NOT NULL,
	created_at DATETIME NOT NULL,
	happened_at DATETIME NOT NULL
);
CREATE UNIQUE INDEX index_tr
ON Transactions (tr_id);

--File Insert: Transactions
INSERT INTO Transactions (tr_id, device_id, product_name, product_sku, category_name, amount, tr_status, card_number, cvv, created_at, happened_at)
SELECT *
FROM OPENROWSET(
    'Microsoft.ACE.OLEDB.16.0',
    'Excel 12.0;Database=C:\SUMUPFILES\transaction.xlsx;HDR=YES;IMEX=1',
    'SELECT id, device_id, product_name,
	right(product_sku, 13),
	category_name, amount, status, 
	0+replace(card_number, '' '', ''''),
	cvv, created_at, happened_at FROM [transaction.csv$]'
);

--Check Table: Transactions
SELECT * FROM Transactions;
