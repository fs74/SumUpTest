# SumUpTest

## Model
* Built on SQL Server 16.0.1000 LocalDB.
* The 3 XLSX files were inserted into 3 tables with the same columns.
  * Store loaded first with store_id as primary key.
  * Deviced loaded second with device_id as primary key and store_id as foreign key.
  * Transactions loaded third with tr_id as primary key and device_id as foreign key.
  * Some columns were renamed to avoid ambiguity or usage of reserved words.
  * Transactions/product_sku processed to remove 'v' letter in some rows.
  * Transactions/card_number processed to remove spaces in some rows.
* Assumed that all information is correct despite some coherence issues:
  * Some card_number have too many digits.
  * product_name and product_sku do not match between rows, even at the same store_id.

## Files
* Besides the provided files, two .sql files are loaded:
  * 1_DatabaseBuilding.sql contains the steps performed sequentially to build the model.
    * Each table is created first, and then populated with the XLSX files via OPENROWSET using Microsoft.ACE.OLEDB.16.0.
    * It may be necessary to set with SQL Server Configuration Manager the SQL Service property "Log on as" to "Built-in account/Local System" to replicate.
    * It may be necessary to manually add registry key to 'HKEY LOCAL MACHINE\SOFTWARE\Microsoft\Office\ClickToRun\REGISTRY\MACHINE\Software\Microsoft\Office\16.0\Access Connectivity Engine\Engines\Excel\' with the pair ImportMixedTypes:Text in case IMEX=1 argument is not working properly.
  * 2_Q&A.sql contains the queries needed to answer the questions asked in the Word file.
    * For all questions is assumed that only tr_status = 'accepted' transactions are valid.
    * It's assumed that SKU+Store is a correct uniqueness identifier.
    * For the last question, is assumed that no transactions of the relevant stores are missing between the 1st and the 5th.
